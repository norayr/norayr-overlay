EAPI=8

DESCRIPTION="Game of Trees (portable) – a simple Git-compatible VCS (got/tog/gotd)"
HOMEPAGE="https://gameoftrees.org"
SRC_URI="https://gameoftrees.org/releases/portable/got-portable-${PV}.tar.gz -> got-portable-${PV}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE="webd gitwrapper"

RDEPEND="
  sys-libs/ncurses:=
  dev-libs/libbsd
  app-crypt/libmd
  sys-apps/util-linux:=
  sys-libs/zlib
  || ( dev-libs/libretls dev-libs/libressl:0= )
  webd? ( dev-libs/libevent )
  gitwrapper? ( dev-vcs/git )
"
BDEPEND="
  virtual/pkgconfig
  sys-devel/bison
"

S="${WORKDIR}/got-portable-${PV}"

RESTRICT="test"

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
    elog "gitwrapper installed. To use it, you may symlink /usr/bin/git-{receive,upload}-pack"
    elog "to gitwrapper, while keeping Git's originals in /usr/libexec/git-core."
  fi
  if use webd ; then
    elog "gotwebd built. Integrate it with your web server as needed."
  fi
}
