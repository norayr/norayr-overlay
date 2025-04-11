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
  # Adjust install path and flags
  sed -i \
    -e 's|/usr/local|/usr|g' \
    -e 's|CFLAGS =|CFLAGS +=|g' \
    Makefile || die
}

src_compile() {
  local gtk2_cflags=$(pkg-config --cflags gtk+-2.0)
  local gtk2_libs=$(pkg-config --libs gtk+-2.0)

  emake -C src clean

  # Build all objects using emake but don’t let it link
  emake -C src \
    CFLAGS="${CFLAGS} ${gtk2_cflags} -DMT_VERSION=\\\"${PV}\\\" -fcommon" \
    LDFLAGS="${LDFLAGS}" \
    PREFIX=/usr \
    mtpaint.o  # dummy target to suppress default linking

  # Link manually
  local objlist="main.o mainwindow.o inifile.o png.o memory.o canvas.o otherwindow.o mygtk.o \
    viewer.o polygon.o layer.o info.o wu.o prefs.o ani.o mtlib.o toolbar.o \
    channels.o csel.o shifter.o spawn.o font.o fpick.o icons.o cpick.o \
    thread.o vcode.o"

  pushd src > /dev/null || die
  ${CC} ${CFLAGS} -o mtpaint ${objlist} \
    ${LDFLAGS} ${gtk2_libs} -lX11 -lm -lpng -lz || die "linking failed"
  popd > /dev/null || die
}


src_install() {
  dobin src/mtpaint
  dodoc README NEWS
  doicon src/pixmaps/icon48.png
  make_desktop_entry mtpaint "mtPaint" /usr/share/icons/hicolor/48x48/apps/mtpaint.png
}
