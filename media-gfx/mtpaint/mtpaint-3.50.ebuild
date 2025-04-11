# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Simple painting program for creating icons, pixel-based artwork, and manipulating digital photos"
HOMEPAGE="https://mtpaint.sourceforge.net/"
SRC_URI="mirror://sourceforge/mtpaint/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

DEPEND="
  media-libs/libpng:0=
  media-libs/libjpeg-turbo:0=
  x11-libs/gtk+:2
  nls? ( sys-devel/gettext )
"

RDEPEND="${DEPEND}"

BDEPEND="virtual/pkgconfig"

src_prepare() {
  default
  # Fix path for installing docs and stripping
  sed -i \
    -e 's|/usr/local|/usr|g' \
    -e 's|CFLAGS =|CFLAGS +=|g' \
    makefile || die
}

src_compile() {
  emake CFLAGS="${CFLAGS}" PREFIX=/usr
}

src_install() {
  emake PREFIX="${D}/usr" install

  dodoc README* NEWS TODO
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/pixmaps/icon48.png Graphics
}
