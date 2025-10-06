EAPI=8

inherit git-r3 autotools

DESCRIPTION="Game of Trees (portable, live) – a simple Git-compatible VCS (got/tog/gotd)"
HOMEPAGE="https://gameoftrees.org"
EGIT_REPO_URI="https://codeberg.org/stsp/got-portable.git"
EGIT_BRANCH="portable"

LICENSE="ISC"
SLOT="0"
IUSE="webd gitwrapper"

RDEPEND="
  sys-libs/ncurses:=
  dev-libs/libbsd
  app-crypt/libmd
  virtual/libuuid
  sys-libs/zlib
  || ( dev-libs/libretls dev-libs/libressl:0= )
  webd? ( dev-libs/libevent )
  gitwrapper? ( dev-vcs/git )
"
BDEPEND="
  virtual/pkgconfig
  sys-devel/bison
"

RESTRICT="test"

src_prepare() {
  default
  eautoreconf
}

src_configure() {
  local myeconfargs=(
    --prefix=/usr
    --libexecdir=/usr/libexec/got
  )
  if use gitwrapper ; then
    myeconfargs+=( --with-gitwrapper-git-libexec-path=/usr/libexec/git-core )
  fi
  econf "${myeconfargs[@]}"
}

src_compile() { emake; }

src_install() { emake DESTDIR="${D}" install; }

pkg_postinst() {
  if use gitwrapper ; then
    elog "gitwrapper installed; you may replace git-{receive,upload}-pack in /usr/bin with"
    elog "symlinks to gitwrapper (upstream README.portable explains the flow)."
  fi
  if use webd ; then
    elog "gotwebd built. Configure your web server accordingly."
  fi
}
