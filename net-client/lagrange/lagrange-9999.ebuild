# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="A Beautiful Gemini Client (live ebuild from dev branch)"
HOMEPAGE="https://gmi.skyjake.fi/lagrange/"
EGIT_REPO_URI="https://github.com/skyjake/lagrange.git"
EGIT_BRANCH="dev"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS=""
IUSE="+opus +jxl tui sse41"

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
    opus? ( media-libs/opusfile )
    jxl? ( media-libs/libjxl )
    dev-libs/the_Foundation
    tui? ( dev-libs/sealcurses )
"
RDEPEND="${DEPEND}"

BDEPEND="
    virtual/pkgconfig
"

DOCS=( README.md )

src_prepare() {
    cmake_src_prepare

    # Remove bundled submodules if present
    rm -rf lib/the_Foundation lib/sealcurses lib/harfbuzz lib/fribidi || die

    # Force system libraries
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
        -DENABLE_OPUS=$(usex opus)
        -DENABLE_JXL=$(usex jxl)
        -DTFDN_ENABLE_SSE41=$(usex sse41)
    )
    cmake_src_configure
}

src_install() {
    cmake_src_install

    insinto /usr/share/applications
    doins "${BUILD_DIR}/fi.skyjake.Lagrange.desktop"

    insinto /usr/share/icons/hicolor/256x256/apps
    doins "${S}/res/lagrange-256.png"

    doman "${S}/res/lagrange.1"
}
