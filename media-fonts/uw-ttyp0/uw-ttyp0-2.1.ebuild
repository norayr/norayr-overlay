# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Multiscript monospaced bitmap fonts for X11 and the Linux console"
HOMEPAGE="https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/"
SRC_URI="https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/${P}.tar.gz"

LICENSE="TTYP0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bdf"

BDEPEND="
	app-text/bdf2psf
	X? ( x11-apps/fonttosfnt )
"

# OTB is the Fontconfig/Xft format used by e.g. xterm -fa.
FONT_SUFFIX="otb"
FONT_S="${S}/genotb"
FONTDIR="/usr/share/fonts/uw-ttyp0"

# These are upstream Linux-console repertoire names.  Installed filenames use
# clearer script names, because the upstream name "Koi" is misleading when the
# console itself is running in UTF-8/Unicode mode.
CONSOLE_CODESETS="Arm Geo Koi"
CONSOLE_SIZES="11 12 13 14 15 16 17 18 22 30 15b 16b 17b 18b"

src_configure() {
	# Upstream ships a small custom configure script, not Autoconf.
	# econf cannot be used because it adds --build, --host, etc.
	./configure \
		--prefix="${EPREFIX}/usr" \
		--otbdir="${EPREFIX}${FONTDIR}" \
		--conslinuxdir="${EPREFIX}/usr/share/consolefonts/uw-ttyp0" \
		|| die "configure failed"
}

src_compile() {
	local -a make_args=(
		GEN_CONS_LINUX=1
		CODESETS_CONS_LINUX="${CONSOLE_CODESETS}"
		SIZES_CONS_LINUX="${CONSOLE_SIZES}"
	)

	use X && make_args+=( GEN_OTB=1 )

	emake "${make_args[@]}"
}

src_install() {
	local size upstream installed src

	# Unicode OTB strikes for Fontconfig/Xft applications such as xterm -fa.
	if use X; then
		font_src_install
	fi

	# Linux virtual-console PSF fonts.  The files contain Unicode mappings;
	# Arm/Geo/Koi are only upstream names for the selected glyph repertoires.
	insinto /usr/share/consolefonts/uw-ttyp0
	for size in ${CONSOLE_SIZES}; do
		for upstream in Arm Geo Koi; do
			case ${upstream} in
				Arm) installed=Armenian ;;
				Geo) installed=Georgian ;;
				Koi) installed=Cyrillic ;;
			esac

			src="genconslinux/Ttyp0-${size}-${upstream}.psf.gz"
			[[ -f ${src} ]] || die "missing generated console font: ${src}"
			newins "${src}" "Ttyp0-${size}-${installed}.psf.gz"
		done
	done

	# Optional raw BDF versions of the same three script-oriented repertoires.
	# These LC_* BDF files are generated as inputs to the Linux-console build.
	if use bdf; then
		insinto /usr/share/fonts/uw-ttyp0/bdf
		for size in ${CONSOLE_SIZES}; do
			for upstream in Arm Geo Koi; do
				case ${upstream} in
					Arm) installed=Armenian ;;
					Geo) installed=Georgian ;;
					Koi) installed=Cyrillic ;;
				esac

				src="genbdf/t0-${size}-LC_${upstream}.bdf"
				[[ -f ${src} ]] || die "missing generated BDF font: ${src}"
				newins "${src}" "Ttyp0-${size}-${installed}.bdf"
			done
		done
	fi

	# Keep upstream's repertoire descriptions; they are useful when choosing
	# other 256/512-glyph console subsets later.
	dodoc doc/LinuxCodeSetSelector.html
	docinto LinuxCodeSets
	dodoc doc/LinuxCodeSets/*.csdescr
}

pkg_postinst() {
	font_pkg_postinst

	elog "Linux virtual-console fonts are Unicode-mapped PSF fonts."
	elog "Run the console in UTF-8/Unicode mode and select the script repertoire"
	elog "you want with setfont.  For a large 30-pixel font:"
	elog
	elog "  Armenian:"
	elog "    setfont /usr/share/consolefonts/uw-ttyp0/Ttyp0-30-Armenian.psf.gz"
	elog "  Georgian:"
	elog "    setfont /usr/share/consolefonts/uw-ttyp0/Ttyp0-30-Georgian.psf.gz"
	elog "  Cyrillic:"
	elog "    setfont /usr/share/consolefonts/uw-ttyp0/Ttyp0-30-Cyrillic.psf.gz"
	elog
	elog "Regular sizes installed: 11 12 13 14 15 16 17 18 22 30 pixels."
	elog "Bold console variants are also installed for 15b 16b 17b 18b."
	elog
	elog "For OpenRC boot, put the chosen full path in /etc/conf.d/consolefont, e.g.:"
	elog "  consolefont=\"/usr/share/consolefonts/uw-ttyp0/Ttyp0-30-Armenian.psf.gz\""
	elog "Then enable the service:"
	elog "  rc-update add consolefont boot"

	if use X; then
		elog
		elog "For xterm/Xft, the OTB family is 'Ttyp0 OTB', for example:"
		elog "  xterm -sb -u8 -fa 'Ttyp0 OTB' -fs 16"
	fi

	if use bdf; then
		elog
		elog "Raw BDF Armenian, Georgian and Cyrillic repertoire fonts were installed in:"
		elog "  /usr/share/fonts/uw-ttyp0/bdf"
	fi
}
