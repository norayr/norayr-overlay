# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="VueScan is a scanning application supporting hundreds of scanners"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="
	amd64? ( https://www.hamrick.com/oldfiles/vuex6497.tgz -> vuescan-9.7.99-amd64.tgz )
	x86?   ( https://www.hamrick.com/oldfiles/vuex3297.tgz -> vuescan-9.7.99-x86.tgz )
	arm64? ( https://www.hamrick.com/oldfiles/vuea6497.tgz -> vuescan-9.7.99-arm64.tgz )
"

LICENSE="vuescan"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
RESTRICT="mirror bindist strip"

RDEPEND="
	x11-libs/gtk+:2
	x11-libs/gdk-pixbuf
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/libX11
	x11-libs/libSM
	dev-libs/glib
	sys-libs/zlib
	virtual/libudev
	>=sys-libs/glibc-2.27
"

DEPEND=""

S="${WORKDIR}/VueScan"

src_install() {
	# Binary
	exeinto /usr/local/bin
	doexe vuescan

	# Icon
	insinto /usr/share/icons/hicolor/scalable/apps
	doins vuescan.svg

	# Udev rule
	insinto /lib/udev/rules.d
	newins vuescan.rul 60-vuescan.rules

	# Optional: README
	dodoc README.txt
}
