EAPI=8

inherit multilib

DESCRIPTION="Vishap Oberon Compiler with optional native shared modules and vish"
HOMEPAGE="https://github.com/vishapoberon/compiler"
# Local development snapshot: not an upstream release or a remote live checkout.
SRC_URI="${P}.tar.gz"
S="${WORKDIR}/${P}"
RESTRICT="fetch"

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

pkg_nofetch() {
	einfo "This ebuild tests a local VOC development snapshot."
	einfo "Copy ${P}.tar.gz into ${DISTDIR} before emerging this package."
	einfo "Snapshot and test instructions are in doc/GentooModular.md in the VOC checkout."
}

modular_make() {
	emake -j1 -f src/tools/vish/Makefile \
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
		export LD_LIBRARY_PATH="${S}/build/vish/modules/2:${S}/install/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
		modular_make test-library test demo
		modular_make demo HOST_MODE=mD
	fi
}

src_install() {
	local libdir="/usr/$(get_libdir)"
	unset OBERON MODULES VOCROOT VOCLIBDIR
	emake -j1 PREFIX=/usr LIBDIR="${libdir}" DESTDIR="${D}" install

	if use modular; then
		modular_make install-modular DESTDIR="${D}" \
			INSTALL_ROOT=/usr/share/voc INSTALL_LIBDIR="${libdir}"
		dobin build/vish/vish
		dodoc doc/SharedModules.md doc/GentooModular.md
		docinto examples/shared-libraries
		dodoc src/test/shared-libraries/{LibraryDemo.Mod,LibraryMain.Mod,README.md}
	fi
	if use ocat; then
		newbin OCatCmd ocat
	fi
}

pkg_postinst() {
	if use modular; then
		elog "The optional shared modules are in /usr/$(get_libdir)/voc/modular/2."
		elog "Use voc -md Main.Mod (shared core) or voc -mD Main.Mod (embedded core)."
		elog "vish runs exported Module.Command procedures; -m/-M keep conventional linking."
		elog "See /usr/share/doc/${PF}/GentooModular.md* for the test guide."
	fi
}
