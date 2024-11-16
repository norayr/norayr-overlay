# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A Beautiful Gemini Client"
HOMEPAGE="https://gmi.skyjake.fi/lagrange/"
SRC_URI="https://github.com/skyjake/lagrange/releases/download/v${PV}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE="tui sse41"

DEPEND="
    media-libs/libsdl2
    dev-libs/libpcre
    dev-libs/libunistring
    dev-libs/openssl:0=
    sys-libs/zlib
    media-libs/harfbuzz
    dev-libs/fribidi
    media-sound/mpg123
    media-libs/libwebp
    media-libs/opusfile
    dev-libs/the_Foundation
    dev-libs/sealcurses
"
RDEPEND="${DEPEND}"

BDEPEND="
    virtual/pkgconfig
"

DOCS=( README.md )

src_prepare() {
    cmake_src_prepare

    # Remove bundled submodules
    rm -rf lib/the_Foundation lib/sealcurses lib/harfbuzz lib/fribidi || die

    # Adjust CMakeLists.txt to use system libraries
    sed -i \
        -e '/add_subdirectory(lib\/the_Foundation)/d' \
        -e '/add_subdirectory(lib\/harfbuzz)/d' \
        -e '/add_subdirectory(lib\/fribidi)/d' \
        -e '/add_subdirectory(lib\/sealcurses)/d' \
        -e 's|if (NOT TARGET the_Foundation::the_Foundation)|if (FALSE)|' \
        -e 's|if (NOT TARGET harfbuzz-lib)|if (FALSE)|' \
        -e 's|if (NOT TARGET fribidi-lib)|if (FALSE)|' \
        -e 's|if (NOT TARGET sealcurses-static)|if (FALSE)|' \
        CMakeLists.txt || die
}

src_configure() {
    local mycmakeargs=(
        -DENABLE_TUI=$(usex tui)
        -DENABLE_STATIC=OFF
        -DENABLE_FRIBIDI=ON
        -DENABLE_HARFBUZZ=ON
        -DENABLE_WEBP=ON
        -DENABLE_MPG123=ON
        -DENABLE_OPUS=ON
        -DTFDN_ENABLE_SSE41=$(usex sse41)
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install

    # Install desktop entry and icons
    insinto /usr/share/applications
    doins "${S}_build/fi.skyjake.Lagrange.desktop"

    insinto /usr/share/icons/hicolor/256x256/apps
    doins "${S}/res/lagrange-256.png"

    # Install man page
    doman "${S}/res/lagrange.1"
}
