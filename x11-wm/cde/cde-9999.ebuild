# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="The Common Desktop Environment, the classic UNIX desktop"
HOMEPAGE="https://sourceforge.net/projects/cdesktopenv/"
EGIT_REPO_URI="https://git.code.sf.net/p/cdesktopenv/code"
EGIT_BRANCH="master"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""

# The SourceForge repository contains the actual CDE source in cde/.
S="${WORKDIR}/${P}/cde"

BDEPEND="
	dev-build/autoconf
	dev-build/automake
	dev-build/libtool
	dev-build/make
	sys-devel/bison
	sys-devel/flex
	sys-devel/m4
	sys-devel/patch
	virtual/pkgconfig
"

# Based on upstream LinuxBuild wiki + old cde-9999 ebuild deps.
# https://sourceforge.net/p/cdesktopenv/wiki/LinuxBuild/
DEPEND="
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXft
	x11-libs/libXinerama
	x11-libs/libXpm
	>=x11-libs/motif-2.3
	x11-libs/libXaw
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXrender
	net-libs/libtirpc

	x11-apps/xset
	x11-apps/xrdb
	x11-apps/sessreg
	x11-misc/xbitmaps

	virtual/jpeg
	media-libs/freetype:2

	dev-lang/tcl
	app-shells/ksh
	app-arch/ncompress
	app-text/opensp

	dev-libs/openssl:0=
	sys-libs/libutempter
	dev-db/lmdb

	sys-libs/pam
	net-nds/rpcbind

	media-fonts/font-adobe-100dpi
	media-fonts/font-adobe-utopia-100dpi
	media-fonts/font-bh-100dpi
	media-fonts/font-bh-lucidatypewriter-100dpi
	media-fonts/font-bitstream-100dpi
"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	# Git checkouts need the autotools files generated first.
	einfo "Running upstream autogen.sh"
	./autogen.sh || die "autogen.sh failed"
}

src_configure() {
	# Do not force an older C dialect here.  Current master contains the
	# upstream GCC 15 / C23 port; building with the compiler default also
	# exercises those fixes.
	econf \
		--sysconfdir=/etc \
		--localstatedir=/var
}

src_compile() {
	default
}

src_install() {
	default

	dodir /var/dt
	fperms 0777 /var/dt || die

	dodir /usr/spool/calendar
}

pkg_postinst() {
	elog "To start CDE for a single user:"
	elog "  startx /usr/dt/bin/Xsession"
	elog
	elog "For dtlogin (graphical login manager), see the upstream LinuxBuild wiki:"
	elog "  https://sourceforge.net/p/cdesktopenv/wiki/LinuxBuild/"
	elog
	elog "Some CDE components (ToolTalk, calendar manager, etc.) require rpcbind."
	elog "Ensure the rpcbind service is running before using those applications."
}
