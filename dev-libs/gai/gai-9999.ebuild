EAPI=8

inherit autotools git-r3 flag-o-matic

DESCRIPTION="General Applet Interface Library"
HOMEPAGE="https://github.com/norayr/gai"
EGIT_REPO_URI="https://github.com/norayr/gai.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+sdl"

DEPEND="
    sdl? ( media-libs/libsdl )
    x11-libs/libX11
    x11-libs/libXpm
    x11-libs/libXt
    x11-libs/libXext
    dev-libs/glib:2"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
    default
    eautoreconf
}

src_configure() {
    append-cflags "-Wno-int-to-pointer-cast -Wno-int-conversion"

    econf $(use_enable sdl)
}

src_install() {
    default
}
