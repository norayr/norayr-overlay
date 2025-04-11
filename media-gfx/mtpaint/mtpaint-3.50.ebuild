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
  local gtk2_cflags=$(pkg-config --cflags gtk+-2.0)
  local gtk2_libs=$(pkg-config --libs gtk+-2.0)

  emake clean
  emake \
    CFLAGS="${CFLAGS} ${gtk2_cflags} -DMT_VERSION=\\\"${PV}\\\" -fcommon" \
    LDFLAGS="${LDFLAGS} ${gtk2_libs} -lX11 -lm -lpng -lz" \
    OBJS="main.o mainwindow.o inifile.o png.o memory.o canvas.o otherwindow.o mygtk.o \
          viewer.o polygon.o layer.o info.o wu.o prefs.o ani.o mtlib.o toolbar.o \
          channels.o csel.o shifter.o spawn.o font.o fpick.o icons.o cpick.o \
          thread.o vcode.o" \
    PREFIX=/usr
}

src_install() {
  emake PREFIX="${D}/usr" install

  dodoc README NEWS
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/pixmaps/icon48.png Graphics
}
