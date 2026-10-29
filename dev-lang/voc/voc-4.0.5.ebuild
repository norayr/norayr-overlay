# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_14 )
inherit flag-o-matic multilib python-any-r1

DESCRIPTION="Vishap Oberon Compiler, bundled libraries and shared-module tools"
HOMEPAGE="https://github.com/vishapoberon/compiler"
SRC_URI="https://github.com/vishapoberon/compiler/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/compiler-${PV}"

LICENSE="GPL-2 GPL-3 LGPL-2+ LGPL-3 BSD Unicode-3.0 bindings? ( LGPL-2.1 MIT )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gcc clang tcc ocat +modular +network +bindings test"
REQUIRED_USE="
	^^ ( gcc clang tcc )
	bindings? ( modular )
	modular? ( kernel_linux elibc_glibc )
	network? ( kernel_linux )
"
# Imported XMPP licensing is unresolved; retain the source records and notices.
RESTRICT="mirror bindist !test? ( test )"

DEPEND="bindings? ( x11-libs/libX11 x11-libs/cairo media-libs/raylib )"
RDEPEND="
	${DEPEND}
	gcc? ( sys-devel/gcc )
	clang? ( llvm-core/clang )
	tcc? ( dev-lang/tcc )
	!dev-oberon/lists
	!dev-oberon/opts
	!dev-oberon/strutils
"
BDEPEND="
	dev-build/make
	dev-util/patchelf
	gcc? ( sys-devel/gcc )
	clang? ( llvm-core/clang )
	tcc? ( dev-lang/tcc )
	!tcc? ( elibc_glibc? ( sys-libs/glibc[static-libs] ) )
	bindings? ( virtual/pkgconfig )
	test? (
		${PYTHON_DEPS}
		network? ( dev-libs/openssl )
	)
"

# Linux XMPP adapters follow their Internet/TLS dependencies in model 2.
VOC_NETWORK_PORTS='$(MODULAR_INTERNET) $(MODULAR_HTTP) $(MODULAR_TLS) $(MODULAR_HTTPS) $(MODULAR_GEMINI) $(if $(filter 2,$(MODEL)),xmpp/XmppTCP norayr/xmpp-publish/XmppPublisher)'

pkg_setup() {
	if use test; then
		python_setup
	fi
}

src_prepare() {
	default
	eapply "${FILESDIR}/${P}-optional-tests.patch"
}

voc_environment() {
	unset OBERON MODULES VOC_MODULE_PATH VOC_SYM_PATH VOC_RUNPATH
	export VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib"
	export LD_LIBRARY_PATH="${S}/install/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

voc_make() {
	# Keep the self-hosted compiler's conservative stack roots unoptimized.
	emake -j1 PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		CFLAGS="${CFLAGS}" COMPILE="${CC} ${CFLAGS} -fPIC -O0 ${LDFLAGS}" \
		"MODULAR_LINUX_PORTS=${VOC_NETWORK_PORTS}" "$@"
}

modular_make() {
	# Preserve literal $ORIGIN through make and recursive example builds.
	emake -j1 -f src/tools/hresh/Makefile \
		VOC="${S}/voc" VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib" \
		RESOURCE_ROOT="${EPREFIX}/usr/share/voc" INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		VOC_RUNPATH="\$\$ORIGIN:${EPREFIX}/usr/$(get_libdir)/voc/modular/2" \
		WITH_X11="$(usex bindings 1 0)" WITH_CAIRO="$(usex bindings 1 0)" \
		WITH_RAYLIB="$(usex bindings 1 0)" WITH_NETWORK="$(usex network 1 0)" \
		"MODULAR_LINUX_PORTS=${VOC_NETWORK_PORTS}" MODEL=2 "$@"
}

src_compile() {
	filter-lto
	# Keep generated open-array calls rooted across conservative collections.
	filter-flags '-O*'
	append-flags -O0
	append-flags -fno-strict-aliasing
	# Numeric converters require separately rounded floating-point operations.
	append-flags -ffp-contract=off
	if use gcc; then
		export CC=gcc
	elif use clang; then
		export CC=clang
	else
		export CC=tcc
		export CFLAGS="$(test-flags-CC ${CFLAGS})"
		export LDFLAGS="$(CCLD=tcc test-flags-CCLD ${LDFLAGS})"
	fi

	voc_environment
	voc_make WITH_NETWORK="$(usex network 1 0)"
	if use modular; then
		modular_make libraries all
		use bindings && modular_make bindings
	fi
	if use ocat; then
		mkdir -p build/ocat || die
		(
			cd build/ocat || die
			"${S}/voc" -O2 -sM "${S}/src/tools/ocat/OCatCmd.Mod" \
				|| die "Failed to build ocat"
		) || die
	fi
	if use network; then
		mkdir -p build/xmpp-publish || die
		(
			cd build/xmpp-publish || die
			"${S}/voc" -O2 -sm "${S}/src/examples/network/xmpp-publish/XmppPublish.Mod" \
				|| die "Failed to build xmpp-publish"
		) || die
	fi
}

src_test() {
	python_setup
	voc_environment
	# These tests use bundled fixtures and local loopback peers.
	voc_make confidence WITH_NETWORK="$(usex network 1 0)"
	emake -j1 -C src/ports/xml test conformance limits fuzz VOC="${S}/voc"
	local model
	for model in 2 C; do
		emake -j1 -C src/ports/punycode test conformance VOC="${S}/voc" MODEL="${model}"
	done
	emake -j1 -C src/ports/xmpp test VOC="${S}/voc"
	if use network; then
		emake -j1 -C src/ports/xmpp network-test VOC="${S}/voc"
		emake -j1 -C src/ports/norayr/xmpp-publish test network-test VOC="${S}/voc"
	fi
	if use modular; then
		export LD_LIBRARY_PATH="${S}/build/hresh/modules/2:${LD_LIBRARY_PATH}"
		modular_make test test-tools test-library demo
		use bindings && modular_make test-bindings
		modular_make demo HOST_MODE=mD
		emake -j1 -C src/examples/module-tutorial test \
			VOC="${S}/voc" HRESH_BUILD="${S}/build/hresh"
	fi
}

src_install() {
	voc_environment
	voc_make DESTDIR="${D}" install
	if use modular; then
		local target=install-modular
		use bindings && target=install-modular-bindings
		modular_make "${target}" DESTDIR="${D}" \
			INSTALL_ROOT="${EPREFIX}/usr/share/voc"
		dobin build/hresh/hresh
		patchelf --set-rpath "${EPREFIX}/usr/$(get_libdir)/voc/modular/2" \
			"${ED}/usr/bin/hresh" || die
		dodoc doc/SharedModules.md doc/ModuleTutorial.md
		docinto examples/shared-libraries
		dodoc src/examples/shared-libraries/{LibraryDemo.Mod,LibraryMain.Mod,readme.md}
		docinto examples/module-tutorial
		dodoc src/examples/module-tutorial/{Commands.Mod,Main.Mod}
	fi
	local model
	for model in 2 C; do
		patchelf --set-soname "libvoc-O${model}.so" \
			"${ED}/usr/$(get_libdir)/libvoc-O${model}.so" || die
	done
	use ocat && newbin build/ocat/OCatCmd ocat
	if use network; then
		newbin build/xmpp-publish/XmppPublish xmpp-publish
		docinto examples/xmpp-publish
		dodoc src/examples/network/xmpp-publish/readme.md
	fi
	docinto
	dodoc readme.md doc/ReleaseNotes-4.0.md doc/ReleaseValidation-4.0.5.md
	docinto ports
	dodoc src/ports/readme.md
	local file
	while IFS= read -r -d '' file; do
		docinto "ports/$(dirname "${file#src/ports/}")"
		dodoc "${file}"
	done < <(find src/ports -type f \( -iname 'license*' -o -iname 'copying*' \
		-o -iname 'notice*' -o -name 'PORT*.toml' \) -print0)
}

pkg_postinst() {
	elog "The bundled libraries include lists, opts, strutils, XML and portable XMPP."
	elog "Rebuild existing Oberon programs and shared modules after upgrading."
	use network && elog "xmpp-publish publishes one configured UTF-8 microblog entry over verified TLS."
	if use modular; then
		elog "Shared modules are in ${EPREFIX}/usr/$(get_libdir)/voc/modular/2."
		elog "hresh runs Module.Command procedures; none also runs as a standalone editor."
		elog "See ${EPREFIX}/usr/share/doc/${PF}/ModuleTutorial.md* for usage."
	fi
	if use tcc; then
		ewarn "TCC can emit ELF text relocations and omit GNU-stack metadata; prefer GCC or Clang for hardened builds."
	fi
	ewarn "Bundled XMPP licensing remains unconfirmed; consult the installed source records before redistribution."
}
