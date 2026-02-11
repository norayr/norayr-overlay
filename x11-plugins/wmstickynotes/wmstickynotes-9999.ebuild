EAPI=8

inherit git-r3 autotools

DESCRIPTION="sticky notes app for Window Maker"
HOMEPAGE="https://github.com/norayr/wmstickynotes"
EGIT_REPO_URI="https://github.com/norayr/wmstickynotes.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND="x11-libs/gtk+:2
  x11-libs/libX11
  virtual/pkgconfig
  dev-build/automake
  dev-build/autoconf
  dev-build/libtool"
RDEPEND="${DEPEND}"

src_prepare() {
  default
  eautoreconf
}
