EAPI=8

inherit autotools git-r3

DESCRIPTION="sticky notes app for windowmaker, norayr's fork"
HOMEPAGE="https://github.com/norayr/wmstickynotes"
EGIT_REPO_URI="https://github.com/norayr/wmstickynotes.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~ppc"
IUSE=""

DEPEND="x11-libs/gtk+:2
	x11-libs/libX11
	virtual/pkgconfig
	sys-devel/automake
	sys-devel/autoconf
	sys-devel/libtool"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
	# eapply "${FILESDIR}"/wmstickynotes-0.7-clang16.patch  # Optional
}
