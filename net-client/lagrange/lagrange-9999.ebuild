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
IUSE="+gui ncurses +bidi +harfbuzz mp3 +opus +jxl +webp sse41"

REQUIRED_USE="|| ( gui ncurses )"

DEPEND="
    dev-libs/libpcre
    dev-libs/libunistring
    dev-libs/openssl:0=
    sys-libs/zlib
    dev-libs/the_Foundation

    gui? (
        media-libs/libsdl2
        bidi? ( dev-libs/fribidi )
        harfbuzz? ( media-libs/harfbuzz )
        mp3? ( media-sound/mpg123 )
        opus? ( media-libs/opusfile )
        webp? ( media-libs/libwebp )
        jxl? ( media-libs/libjxl )
    )

    ncurses? ( dev-libs/sealcurses )
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
        -DENABLE_GUI=$(usex gui)
        -DENABLE_TUI=$(usex ncurses)

        -DENABLE_STATIC=OFF

        -DENABLE_FRIBIDI=$(usex bidi)
        -DENABLE_HARFBUZZ=$(usex harfbuzz)
        -DENABLE_MPG123=$(usex mp3)
        -DENABLE_OPUS=$(usex opus)
        -DENABLE_WEBP=$(usex webp)
        -DENABLE_JXL=$(usex jxl)

        -DTFDN_ENABLE_SSE41=$(usex sse41)

        -DENABLE_FRIBIDI_BUILD=OFF
        -DENABLE_HARFBUZZ_MINIMAL=OFF
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install

    if use gui ; then
        insinto /usr/share/applications
        doins "${BUILD_DIR}/fi.skyjake.Lagrange.desktop"

        insinto /usr/share/icons/hicolor/256x256/apps
        doins "${S}/res/lagrange-256.png"
    fi

    doman "${S}/res/lagrange.1"
}
