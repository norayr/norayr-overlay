# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Multiscript monospaced bitmap fonts for X11 and system consoles"
HOMEPAGE="https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/"
SRC_URI="https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/${P}.tar.gz"

LICENSE="TTYP0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	app-text/bdf2psf
	x11-apps/fonttosfnt
"

FONT_SUFFIX="otb"
FONT_S="${S}/genotb"
FONTDIR="/usr/share/fonts/uw-ttyp0"

src_configure() {
	# Upstream ships a small custom configure script, not Autoconf.
	# Therefore econf cannot be used: it adds --build, --host, etc.
	./configure \
		--prefix="${EPREFIX}/usr" \
		--otbdir="${EPREFIX}${FONTDIR}" \
		--conslinuxdir="${EPREFIX}/usr/share/consolefonts/uw-ttyp0" \
		|| die "configure failed"
}

src_compile() {
	local file codesets=""

	# Build every 256- and 512-glyph Linux-console codeset supplied
	# by upstream.  The upstream SIZES_CONS_LINUX setting is retained,
	# so all supported Linux-console sizes/styles are generated.
	for file in mgl/conslinux-{256,512}/*.mgl; do
		[[ -f ${file} ]] || die "missing Linux-console codeset file: ${file}"
		codesets+=" ${file##*/}"
	done
	codesets=${codesets//.mgl/}
	[[ -n ${codesets// } ]] || die "no Linux-console codesets found"

	emake \
		GEN_OTB=1 \
		GEN_CONS_LINUX=1 \
		CODESETS_CONS_LINUX="${codesets# }"
}

src_install() {
	# Install all Unicode OTB strikes for Fontconfig/Xft applications.
	font_src_install

	# Install every generated Linux-console PSF font outside /home so
	# it is available during early boot.
	insinto /usr/share/consolefonts/uw-ttyp0
	doins genconslinux/Ttyp0-*.psf.gz

	# Install the upstream descriptions of the console subsets.
	dodoc doc/LinuxCodeSetSelector.html
	docinto LinuxCodeSets
	dodoc doc/LinuxCodeSets/*.csdescr
}

pkg_postinst() {
	font_pkg_postinst

	elog
	elog "To load the 16-pixel Armenian font on a Linux virtual console, run as root:"
	elog "  setfont /usr/share/consolefonts/uw-ttyp0/Ttyp0-16-Arm.psf.gz"
	elog
	elog "For the larger 512-glyph Armenian-oriented codeset, use:"
	elog "  setfont /usr/share/consolefonts/uw-ttyp0/Ttyp0-16-Armn_M.psf.gz"
	elog
	elog "For OpenRC boot, put the chosen full path in /etc/conf.d/consolefont:"
	elog "  consolefont=\"/usr/share/consolefonts/uw-ttyp0/Ttyp0-16-Arm.psf.gz\""
	elog "Then enable the service:"
	elog "  rc-update add consolefont boot"
	elog
	elog "The OTB Fontconfig family name is 'Ttyp0 OTB'.  Example for xterm:"
	elog "  xterm -sb -u8 -fa 'Ttyp0 OTB' -fs 16"
}
