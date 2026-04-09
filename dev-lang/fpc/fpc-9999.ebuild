# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 prefix toolchain-funcs

DESCRIPTION="Free Pascal Compiler live ebuild"
HOMEPAGE="https://www.freepascal.org/"
EGIT_REPO_URI="https://gitlab.com/freepascal.org/fpc/source.git"

BOOTSTRAP_PV="3.2.2"

SRC_URI="
	amd64? ( https://downloads.freepascal.org/fpc/dist/${BOOTSTRAP_PV}/x86_64-linux/fpc-${BOOTSTRAP_PV}.x86_64-linux.tar )
	arm64? ( https://downloads.freepascal.org/fpc/dist/${BOOTSTRAP_PV}/aarch64-linux/fpc-${BOOTSTRAP_PV}.aarch64-linux.tar )
	sparc? ( https://downloads.freepascal.org/fpc/dist/${BOOTSTRAP_PV}/sparc64-linux/fpc-${BOOTSTRAP_PV}.sparc64-linux.tar )
	x86? ( https://downloads.freepascal.org/fpc/dist/${BOOTSTRAP_PV}/i386-linux/fpc-${BOOTSTRAP_PV}.i386-linux.tar )
"

LICENSE="GPL-2 LGPL-2.1-with-linking-exception"
SLOT="0"
IUSE="doc source"
KEYWORDS=""
PROPERTIES="live"
RESTRICT="strip"

# fpc is special: it can't use CFLAGS and LDFLAGS directly
# since those are geared for running through gcc's frontend
QA_FLAGS_IGNORED="
	usr/bin/.*
	usr/lib.*/.*"

BDEPEND="
	dev-vcs/git
	dev-build/make
"

pkg_pretend() {
	if $(tc-getLD) --version | grep -q "GNU gold"; then
		eerror "fpc has several issues with the gold linker and does not easily"
		eerror "permit selection. Please do not use USE=default-gold on binutils."
		die "GNU gold detected from $(tc-getLD)"
	fi
}

src_unpack() {
	case ${ARCH} in
		amd64)
			BOOTSTRAP_FPC_ARCH="x86_64"
			;;
		arm64)
			BOOTSTRAP_FPC_ARCH="aarch64"
			;;
		sparc)
			BOOTSTRAP_FPC_ARCH="sparc64"
			;;
		x86)
			BOOTSTRAP_FPC_ARCH="i386"
			;;
		*)
			die "This ebuild doesn't support ${ARCH}"
			;;
	esac

	git-r3_src_unpack
	unpack "fpc-${BOOTSTRAP_PV}.${BOOTSTRAP_FPC_ARCH}-linux.tar"
	unpack "${WORKDIR}/fpc-${BOOTSTRAP_PV}.${BOOTSTRAP_FPC_ARCH}-linux/binary.${BOOTSTRAP_FPC_ARCH}-linux.tar"
	unpack "${WORKDIR}/base.${BOOTSTRAP_FPC_ARCH}-linux.tar.gz"
}

src_prepare() {
	default

	find "${S}" -name Makefile -exec sed -i 's/ -Xs / /' {} + || die

	# let Portage compress man pages
	if [[ -f "${S}/install/man/Makefile" ]]; then
		sed -i '/find man.* gzip /d' "${S}/install/man/Makefile" || die
	fi

	# make the compiled binary check for fpc.cfg under prefixed /etc
	hprefixify "${S}/compiler/options.pas"

	# pas2js currently fails here when building libpas2jslib.so on some systems
	# with errors like: /usr/bin/ld: read-only segment has dynamic relocations.
	# To keep the live ebuild usable, skip pas2js for now instead of failing the
	# whole compiler build.
	cat > "${S}/utils/pas2js/Makefile" <<-'EOF' || die
	all:
		@true

	install:
		@true

	distinstall:
		@true

	clean:
		@true

	realclean:
		@true
	EOF
}

set_fpc_arch() {
	case ${ARCH} in
		amd64)
			FPC_ARCH="x64"
			FPC_PARCH="x86_64"
			BOOTSTRAP_FPC_ARCH="x86_64"
			;;
		arm64)
			FPC_ARCH="a64"
			FPC_PARCH="aarch64"
			BOOTSTRAP_FPC_ARCH="aarch64"
			;;
		sparc)
			FPC_ARCH="sparc64"
			FPC_PARCH="sparc64"
			BOOTSTRAP_FPC_ARCH="sparc64"
			;;
		x86)
			FPC_ARCH="386"
			FPC_PARCH="i386"
			BOOTSTRAP_FPC_ARCH="i386"
			;;
		*)
			die "This ebuild doesn't support ${ARCH}"
			;;
	esac
}

set_bootstrap_pp() {
	set_fpc_arch
	pp="${WORKDIR}/lib/fpc/${BOOTSTRAP_PV}/ppc${FPC_ARCH}"
	[[ -x ${pp} ]] || die "Bootstrap compiler not found: ${pp}"
}

set_new_pp() {
	set_fpc_arch
	pp="${S}/compiler/ppc${FPC_ARCH}"
}

src_compile() {
	local pp

	set_bootstrap_pp

	# First build with unpacked bootstrap compiler
	emake PP="${pp}" compiler_cycle AS="$(tc-getAS)"

	# Save new compiler from cleaning...
	cp "${S}/compiler/ppc${FPC_ARCH}" "${S}/ppc${FPC_ARCH}.new" || die

	# ...rebuild with freshly built compiler...
	emake PP="${S}/ppc${FPC_ARCH}.new" AS="$(tc-getAS)" compiler_cycle

	# ...and clean up afterwards
	rm "${S}/ppc${FPC_ARCH}.new" || die

	# Using the new compiler
	set_new_pp

	emake PP="${pp}" AS="$(tc-getAS)" rtl_clean

	# ide is in packages and built unconditionally
	emake PP="${pp}" AS="$(tc-getAS)" rtl packages_all utils
}

src_install() {
	local pp
	set_new_pp

	set -- \
		PP="${pp}" \
		FPCMAKE="${S}/utils/fpcm/bin/${FPC_PARCH}-linux/fpcmake" \
		INSTALL_PREFIX="${ED}/usr" \
		INSTALL_DOCDIR="${ED}/usr/share/doc/${PF}" \
		INSTALL_MANDIR="${ED}/usr/share/man" \
		INSTALL_SOURCEDIR="${ED}/usr/lib/fpc/${PV}/source"

	emake "$@" compiler_install rtl_install packages_install utils_install

	dosym "../lib/fpc/${PV}/ppc${FPC_ARCH}" "/usr/bin/ppc${FPC_ARCH}"

	if [[ -d "${S}/install/doc" ]]; then
		emake -C "${S}/install/doc" "$@" installdoc
	fi

	if [[ -d "${S}/install/man" ]]; then
		emake -C "${S}/install/man" "$@" installman
	fi

	use doc && [[ -d "${S}/doc" ]] && dodoc -r "${S}/doc/."

	if use source; then
		shift
		emake PP="${ED}/usr/bin/ppc${FPC_ARCH}" "$@" sourceinstall
		find "${ED}/usr/lib/fpc/${PV}/source" -name '*.o' -delete || die
	fi

	"${ED}/usr/lib/fpc/${PV}/samplecfg" "${ED}/usr/lib/fpc/${PV}" "${ED}/etc" || die

	# set correct prefixed path in config files
	sed -i "s:${ED}:${EPREFIX}:g" "${ED}/etc/fpc.cfg" || die

	if [[ -f "${ED}/etc/fppkg.cfg" ]]; then
		sed -i "s:${ED}::g" "${ED}/etc/fppkg.cfg" || die
	fi
	if [[ -f "${ED}/etc/fppkg/default" ]]; then
		sed -i "s:${ED}::g" "${ED}/etc/fppkg/default" || die
	fi
	if [[ -f "${ED}/usr/lib/fpc/${PV}/ide/text/fp.cfg" ]]; then
		sed -i "s:${ED}::g" "${ED}/usr/lib/fpc/${PV}/ide/text/fp.cfg" || die
	fi

	if [[ -d "${ED}/usr/lib/fpc/lexyacc" ]]; then
		rm -r "${ED}/usr/lib/fpc/lexyacc" || die
	fi

	case ${ARCH} in
		amd64|arm64)
			mkdir -p "${ED}/usr/$(get_libdir)" || die
			if compgen -G "${ED}/usr/lib/*.so" > /dev/null; then
				mv "${ED}"/usr/lib/*.so "${ED}/usr/$(get_libdir)/" || die
			fi
			;;
	esac
}

pkg_postinst() {
	if ! use doc; then
		elog "To read the documentation in the fpc IDE, enable the doc USE flag"
	fi
}
