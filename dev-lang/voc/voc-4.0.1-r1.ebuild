# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic multilib

DESCRIPTION="Vishap Oberon Compiler with optional shared modules and hresh"
HOMEPAGE="https://github.com/vishapoberon/compiler"
SRC_URI="https://github.com/vishapoberon/compiler/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/compiler-${PV}"

LICENSE="GPL-3 LGPL-2 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gcc clang tcc ocat +modular +network +bindings test"
REQUIRED_USE="
	^^ ( gcc clang tcc )
	bindings? ( modular )
	modular? ( kernel_linux elibc_glibc )
	network? ( kernel_linux )
"

DEPEND="bindings? ( x11-libs/libX11 )"
RDEPEND="
	${DEPEND}
	!dev-oberon/lists
	!dev-oberon/opts
	!dev-oberon/strutils
"
BDEPEND="
	dev-build/make
	elibc_glibc? ( sys-libs/glibc[static-libs] )
	gcc? ( sys-devel/gcc )
	clang? ( sys-devel/clang )
	tcc? ( dev-lang/tcc )
	test? (
		dev-lang/python:*
		network? ( dev-libs/openssl )
	)
"

modular_make() {
	# Preserve literal $ORIGIN through make, including recursive example builds.
	emake -j1 -f src/tools/hresh/Makefile \
		VOC="${S}/voc" VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib" \
		RESOURCE_ROOT=/usr/share/voc INSTALL_LIBDIR="/usr/$(get_libdir)" \
		VOC_RUNPATH="\$\$ORIGIN:/usr/$(get_libdir)/voc/modular/2" \
		WITH_X11="$(usex bindings 1 0)" WITH_CAIRO=0 WITH_RAYLIB=0 \
		WITH_NETWORK="$(usex network 1 0)" MODEL=2 "$@"
}

has_separate_bindings() {
	# Keep supporting the published 4.0 archive's unified library target.
	grep -q '^bindings:' src/tools/hresh/Makefile
}

src_compile() {
	local libdir="/usr/$(get_libdir)"
	# Conservative stack roots are incompatible with whole-program optimization.
	filter-lto
	if use gcc; then
		export CC=gcc
	elif use clang; then
		export CC=clang
	else
		export CC=tcc
		export LDFLAGS="$(CCLD=tcc test-flags-CCLD ${LDFLAGS})"
	fi

	unset OBERON MODULES VOC_MODULE_PATH VOC_SYM_PATH VOC_RUNPATH
	export VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib"
	# Bootstrap, self-host, build conventional libraries and run confidence tests.
	emake -j1 PREFIX=/usr LIBDIR="${libdir}" WITH_NETWORK="$(usex network 1 0)"

	if use modular; then
		modular_make libraries all
		if use bindings && has_separate_bindings; then
			modular_make bindings
		fi
	fi

	if use ocat; then
		local os datamodel compiler flavour symdir
		os=$(awk -F= '/^OS=/{print $2}' Configuration.Make) || die
		datamodel=$(awk -F= '/^DATAMODEL=/{print $2}' Configuration.Make) || die
		compiler=$(awk -F= '/^COMPILER=/{print $2}' Configuration.Make) || die
		flavour="${os}.${datamodel}.${compiler}"
		symdir="${S}/build/${flavour}/2"
		(
			cd "${symdir}" || die
			CFLAGS="${CFLAGS} -I${symdir} -L${symdir}" \
				"${S}/voc" -M "${S}/src/tools/ocat/OCatCmd.Mod" || die "Failed to build ocat"
		) || die
		cp "${symdir}/OCatCmd" "${S}/OCatCmd" || die
	fi
}

src_test() {
	# Only local fixtures and loopback connections are used.
	export LD_LIBRARY_PATH="${S}/build/hresh/modules/2:${S}/install/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
	emake -j1 -C src/test/ports test VOC="${S}/voc" \
		VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib" \
		NETWORK="$(usex network 1 0)"
	if use modular; then
		modular_make test test-tools test-library demo
		if use bindings && has_separate_bindings; then
			modular_make test-bindings
		fi
		modular_make demo HOST_MODE=mD
		VOCROOT="${S}/install" VOCLIBDIR="${S}/build/hresh/modules/2" \
			OBERON="${S}/build/hresh/modules/2" \
			emake -j1 -C src/examples/module-tutorial test \
			VOC="${S}/build/hresh/compiler/voc" HRESH="${S}/build/hresh/hresh"
	fi
}

src_install() {
	local libdir="/usr/$(get_libdir)"
	unset OBERON MODULES VOCROOT VOCLIBDIR
	emake -j1 PREFIX=/usr LIBDIR="${libdir}" DESTDIR="${D}" install

	if use modular; then
		local target=install-modular
		if use bindings && has_separate_bindings; then
			target=install-modular-bindings
		fi
		modular_make "${target}" DESTDIR="${D}" \
			INSTALL_ROOT=/usr/share/voc INSTALL_LIBDIR="${libdir}"
		dobin build/hresh/hresh
		dodoc doc/SharedModules.md doc/ModuleTutorial.md
		docinto examples/shared-libraries
		dodoc src/examples/shared-libraries/{LibraryDemo.Mod,LibraryMain.Mod,readme.md}
		docinto examples/module-tutorial
		dodoc src/examples/module-tutorial/{Commands.Mod,Main.Mod}
	fi
	if use ocat; then
		newbin OCatCmd ocat
	fi
	docinto
	dodoc readme.md doc/ReleaseNotes-4.0.md
	# Preserve the separate upstream licence texts alongside their provenance.
	local package file
	for package in src/ports/* src/ports/*/*; do
		[[ -d ${package} && -f ${package}/PORT.toml ]] || continue
		docinto "ports/${package#src/ports/}"
		for file in "${package}"/{PORT*.toml,LICENSE*,COPYING*,license*}; do
			[[ -f ${file} ]] || continue
			dodoc "${file}"
		done
	done
}

pkg_postinst() {
	elog "lists, opts and strutils are bundled; their separate dev-oberon packages conflict."
	if use modular; then
		elog "Shared modules are in /usr/$(get_libdir)/voc/modular/2."
		elog "Use voc -md Main.Mod (shared core) or voc -mD Main.Mod (embedded core)."
		elog "hresh runs Module.Command procedures; -m/-M retain conventional linking."
		elog "See /usr/share/doc/${PF}/ModuleTutorial.md* for an introduction."
	fi
}
