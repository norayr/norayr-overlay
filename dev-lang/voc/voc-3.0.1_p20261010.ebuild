EAPI=8

inherit multilib

DESCRIPTION="Vishap Oberon Compiler with optional native shared modules and hresh"
HOMEPAGE="https://github.com/vishapoberon/compiler"
# Reproducible snapshot of the compiler's primary branch.
VOC_COMMIT="b8bd8c0393bdb3c72c261bd6873a5162995bdf58"
SRC_URI="https://github.com/vishapoberon/compiler/archive/${VOC_COMMIT}.tar.gz -> ${P}-${VOC_COMMIT}.tar.gz"
S="${WORKDIR}/compiler-${VOC_COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gcc clang tcc ocat +modular X"
REQUIRED_USE="^^ ( gcc clang tcc ) modular? ( !tcc ) X? ( modular )"

DEPEND="X? ( x11-libs/libX11 )"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/make
	gcc? ( sys-devel/gcc )
	clang? ( sys-devel/clang )
	tcc? ( dev-lang/tcc )
"

modular_make() {
	emake -j1 -f src/tools/hresh/Makefile \
		VOC="${S}/voc" VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib" \
		RESOURCE_ROOT=/usr/share/voc WITH_X11="$(usex X 1 0)" MODEL=2 "$@"
}

src_compile() {
	local libdir="/usr/$(get_libdir)"
	if use gcc; then
		export CC=gcc
	elif use clang; then
		export CC=clang
	else
		export CC=tcc
	fi

	unset OBERON MODULES VOC_MODULE_PATH VOC_SYM_PATH VOC_RUNPATH
	export VOCROOT="${S}/install" VOCLIBDIR="${S}/install/lib"
	# Bootstrap from bundled C, then self-host and build the compatibility runtime.
	# Installation paths are final paths; local confidence tests use VOCROOT.
	emake -j1 PREFIX=/usr LIBDIR="${libdir}"

	if use modular; then
		# Keep staged paths out of installed ELF RUNPATHs.
		export VOC_RUNPATH="\$ORIGIN:${libdir}/voc/modular/2"
		modular_make libraries all
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
	if use modular; then
		# Installed RUNPATHs intentionally do not name the temporary build tree.
		export LD_LIBRARY_PATH="${S}/build/hresh/modules/2:${S}/install/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
		modular_make test-library test demo
		modular_make demo HOST_MODE=mD
		VOCROOT="${S}/install" VOCLIBDIR="${S}/build/hresh/modules/2" \
			OBERON="${S}/build/hresh/modules/2" \
			emake -j1 -C src/test/module-tutorial test \
			VOC="${S}/build/hresh/compiler/voc" HRESH="${S}/build/hresh/hresh"
	fi
}

src_install() {
	local libdir="/usr/$(get_libdir)"
	unset OBERON MODULES VOCROOT VOCLIBDIR
	emake -j1 PREFIX=/usr LIBDIR="${libdir}" DESTDIR="${D}" install

	if use modular; then
		modular_make install-modular DESTDIR="${D}" \
			INSTALL_ROOT=/usr/share/voc INSTALL_LIBDIR="${libdir}"
		dobin build/hresh/hresh
		dodoc doc/SharedModules.md doc/ModuleTutorial.md
		docinto examples/shared-libraries
		dodoc src/test/shared-libraries/{LibraryDemo.Mod,LibraryMain.Mod,README.md}
		docinto examples/module-tutorial
		dodoc src/test/module-tutorial/{Commands.Mod,Main.Mod}
	fi
	if use ocat; then
		newbin OCatCmd ocat
	fi
}

pkg_postinst() {
	if use modular; then
		elog "The optional shared modules are in /usr/$(get_libdir)/voc/modular/2."
		elog "Use voc -md Main.Mod (shared core) or voc -mD Main.Mod (embedded core)."
		elog "hresh runs exported Module.Command procedures; -m/-M keep conventional linking."
		elog "See /usr/share/doc/${PF}/ModuleTutorial.md* for a gentle introduction."
	fi
}
