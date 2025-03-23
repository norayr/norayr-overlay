EAPI=8

inherit autotools git-r3

DESCRIPTION="Sherman's Aquarium Dockapp"
HOMEPAGE="https://github.com/norayr/shermans_aquarium"
EGIT_REPO_URI="https://github.com/norayr/shermans_aquarium.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

DEPEND="
	dev-libs/gai
	x11-libs/libX11
	x11-libs/libXpm
	x11-libs/libXt
	x11-libs/libXext"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --with-gai
}

src_compile() {
	default
	# ensure shermans_applet gets built
	emake -C shermans
}

src_install() {
	default
	# manually install shermans_applet binary
	dobin shermans/shermans_applet
}

