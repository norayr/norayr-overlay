EAPI=8

inherit autotools git-r3

DESCRIPTION="Sherman's Aquarium Dockapp"
HOMEPAGE="https://github.com/norayr/shermans_aquarium"
EGIT_REPO_URI="https://github.com/norayr/shermans_aquarium.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE=""

DEPEND="
    dev-libs/gai[sdl]
    x11-libs/libX11
    x11-libs/libXpm
    x11-libs/libXt
    x11-libs/libXext
    dev-libs/glib:2
    x11-libs/gtk+:2"
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
    emake -C shermans
}

src_install() {
    default
    dobin shermans/shermans_applet
}
