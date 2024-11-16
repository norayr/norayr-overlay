# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="SDL-like wrapper for ncurses using the_Foundation library"
HOMEPAGE="https://git.skyjake.fi/skyjake/sealcurses"
EGIT_REPO_URI="https://git.skyjake.fi/skyjake/sealcurses.git"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS=""
IUSE="static-libs"

DEPEND="
    dev-libs/the_Foundation
    sys-libs/ncurses:0=
"

RDEPEND="${DEPEND}"

BDEPEND="
    virtual/pkgconfig
    dev-vcs/git
"

DOCS=( README.md )

src_prepare() {
    cmake_src_prepare

    # Adjust CMakeLists.txt to use system libraries
    sed -i 's|find_package(the_Foundation REQUIRED)|find_package(the_Foundation REQUIRED NO_MODULE)|' CMakeLists.txt || die
}

src_configure() {
    local mycmakeargs=(
        -DSEALCURSES_ENABLE_SHARED=ON
        -DSEALCURSES_ENABLE_STATIC=$(usex static-libs ON OFF)
        -DSEALCURSES_ENABLE_INSTALL=ON
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install

    # Install pkg-config file
    insinto /usr/$(get_libdir)/pkgconfig
    doins "${BUILD_DIR}/sealcurses.pc"

    # Remove static library if USE=-static-libs
    if ! use static-libs; then
        rm -f "${ED}"/usr/$(get_libdir)/libsealcurses.a
    fi
}
