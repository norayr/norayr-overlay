# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Window Maker dockapp to display info via plugins (wminfo)"
HOMEPAGE="https://github.com/gapan/wminfo"
EGIT_REPO_URI="https://github.com/gapan/wminfo.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

# Likely X11 + Xpm dockapp deps
RDEPEND="
  x11-libs/libX11
  x11-libs/libXext
  x11-libs/libXpm
"
DEPEND="${RDEPEND}"

src_prepare() {
  default
}

src_configure() {
  # Upstream build system lives in ./wminfo
  pushd wminfo >/dev/null || die
  ./configure --prefix=/usr || die "configure failed"
  popd >/dev/null || die
}

src_compile() {
  emake -C wminfo
}

src_install() {
  emake -C wminfo DESTDIR="${D}" install

  # man page exists in repo root
  doman man/wminfo.1

  # Install docs + examples/plugins into docdir (not system-wide bin)
  dodoc BUGS ChangeLog INSTALL Plugins-HOWTO README THANKS TODO \
    README.* || die

  # Keep the big plugin trees as documentation/examples
  docinto examples
  dodoc -r contrib samples plugins.* || die
}

