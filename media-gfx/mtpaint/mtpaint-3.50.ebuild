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

  sed -i \
    -e 's|/usr/local|/usr|g' \
    -e 's|CFLAGS =|CFLAGS +=|g' \
    Makefile || die

  eapply "${FILESDIR}/mtpaint-3.50-fix-objlist.patch"
}


src_configure() {
  # Let the project's own script set up _conf.txt
  ./configure || die "configure script failed"
}

src_compile() {
  local gtk2_cflags=$(pkg-config --cflags gtk+-2.0)
  local gtk2_libs=$(pkg-config --libs gtk+-2.0)

  emake -C src clean

  # Manually compile those files before emake mtpaint
  gcc ${CFLAGS} ${gtk2_cflags} -DMT_VERSION="\"${PV}\"" -fcommon -c src/cpick.c -o src/cpick.o || die
  gcc ${CFLAGS} ${gtk2_cflags} -DMT_VERSION="\"${PV}\"" -fcommon -c src/fpick.c -o src/fpick.o || die
  gcc ${CFLAGS} ${gtk2_cflags} -DMT_VERSION="\"${PV}\"" -fcommon -c src/vcode.c -o src/vcode.o || die
  gcc ${CFLAGS} ${gtk2_cflags} -DMT_VERSION="\"${PV}\"" -fcommon -c src/thread.c -o src/thread.o || die

  emake -C src \
    CFLAGS="${CFLAGS} ${gtk2_cflags} -DMT_VERSION=\\\"${PV}\\\" -fcommon" \
    LDFLAGS="${LDFLAGS} ${gtk2_libs} -lX11 -lm -lpng -lz" \
    PREFIX=/usr
}


src_install() {
  dobin src/mtpaint
  dodoc README NEWS
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/icons/hicolor/48x48/apps/mtpaint.png
}
