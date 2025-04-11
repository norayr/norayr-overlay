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
  # Fix install paths and flags in Makefile (uppercase!)
  sed -i \
    -e 's|/usr/local|/usr|g' \
    -e 's|CFLAGS =|CFLAGS +=|g' \
    Makefile || die
}

src_compile() {
  # Use pkg-config to get GTK+2 flags
  local gtk2_cflags=$(pkg-config --cflags gtk+-2.0)
  local gtk2_libs=$(pkg-config --libs gtk+-2.0)

  emake \
    CFLAGS="${CFLAGS} ${gtk2_cflags} -DMT_VERSION=\\\"${PV}\\\"" \
    LDFLAGS="${LDFLAGS} ${gtk2_libs}" \
    PREFIX=/usr
}

src_install() {
  emake PREFIX="${D}/usr" install

  dodoc README NEWS
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/pixmaps/icon48.png Graphics
}
