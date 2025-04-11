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
  # Fix paths and avoid hardcoding /usr/local
  sed -i \
    -e 's|/usr/local|/usr|g' \
    -e 's|CFLAGS =|CFLAGS +=|g' \
    Makefile || die
}

src_configure() {
  # Let the project's own script set up _conf.txt
  ./configure || die "configure script failed"
}

src_compile() {
  emake -C src \
    CFLAGS="${CFLAGS} $(pkg-config --cflags gtk+-2.0) -DMT_VERSION=\\\"${PV}\\\" -fcommon" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs gtk+-2.0) -lX11 -lm -lpng -lz" \
    PREFIX=/usr
}

src_install() {
  dobin src/mtpaint
  dodoc README NEWS
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/icons/hicolor/48x48/apps/mtpaint.png
}
