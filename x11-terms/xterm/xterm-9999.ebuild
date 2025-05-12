# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/thomasdickey.asc

inherit desktop flag-o-matic git-r3 toolchain-funcs xdg

DESCRIPTION="Terminal Emulator for X Windows with optional ReGIS support"
HOMEPAGE="https://invisible-island.net/xterm/"
EGIT_REPO_URI="https://invisible-island.net/xterm/xterm.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="+openpty sixel toolbar truetype unicode Xaw3d xinerama +regis"

DEPEND="
  kernel_linux? ( sys-libs/libutempter )
  media-libs/fontconfig:1.0
  >=sys-libs/ncurses-5.7-r7:=
  x11-apps/xmessage
  x11-libs/libICE
  x11-libs/libX11
  x11-libs/libXaw
  x11-libs/libXft
  x11-libs/libxkbfile
  x11-libs/libXmu
  x11-libs/libXrender
  x11-libs/libXt
  unicode? ( x11-apps/luit )
  Xaw3d? ( x11-libs/libXaw3d )
  xinerama? ( x11-libs/libXinerama )"
RDEPEND="${DEPEND}
  media-fonts/font-misc-misc
  x11-apps/rgb"
DEPEND+=" x11-base/xorg-proto"
BDEPEND="virtual/pkgconfig"

DOCS=( README{,.i18n} ctlseqs.txt )

src_configure() {
  DEFAULTS_DIR="${EPREFIX}"/usr/share/X11/app-defaults

  # Workaround for ncurses[tinfo]
  append-libs $($(tc-getPKG_CONFIG) --libs ncurses)

  local myeconfargs=(
    --disable-full-tgetent
    --disable-imake
    --disable-setgid
    --disable-setuid
    --enable-256-color
    --enable-broken-osc
    --enable-broken-st
    --enable-dabbrev
    --enable-exec-xterm
    --enable-i18n
    --enable-load-vt-fonts
    --enable-logging
    --enable-screen-dumps
    --enable-warnings
    --enable-wide-chars
    --libdir="${EPREFIX}"/etc
    --with-app-defaults="${DEFAULTS_DIR}"
    --with-icon-theme=hicolor
    --with-icondir="${EPREFIX}"/usr/share/icons
    --with-utempter
    --with-x
    $(use_enable openpty)
    $(use_enable sixel sixel-graphics)
    $(use_enable regis regis-graphics)
    $(use_enable toolbar)
    $(use_enable truetype freetype)
    $(use_enable unicode luit)
    $(use_enable unicode mini-luit)
    $(use_with Xaw3d)
    $(use_with xinerama)

