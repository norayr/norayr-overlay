# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Opinionated C11 library for low-level functionality"
HOMEPAGE="https://git.skyjake.fi/skyjake/the_Foundation"
EGIT_REPO_URI="https://git.skyjake.fi/skyjake/the_Foundation.git"
EGIT_COMMIT="v${PV}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE="debug sse41 static-libs"

DEPEND="
    dev-libs/openssl:0=
    dev-libs/libunistring
    sys-libs/zlib
    net-misc/curl
"
RDEPEND="${DEPEND}"

BDEPEND="
    virtual/pkgconfig
    dev-vcs/git
"

DOCS=( README.md )

src_prepare() {
    cmake_src_prepare

    # Adjust CMakeLists.txt to use system libraries and disable submodules
    sed -i \
        -e '/add_subdirectory(lib\/unistring)/d' \
        -e '/add_subdirectory(lib\/zlib)/d' \
        -e 's|find_package(OpenSSL REQUIRED)|find_package(OpenSSL REQUIRED NO_MODULE)|' \
        -e 's|find_package(CURL REQUIRED)|find_package(CURL REQUIRED NO_MODULE)|' \
        CMakeLists.txt || die
}

src_configure() {
    local mycmakeargs=(
        -DTFDN_ENABLE_SSE41=$(usex sse41)
        -DTFDN_ENABLE_DEBUG_OUTPUT=$(usex debug)
        -DTFDN_ENABLE_INSTALL=ON
        -DTFDN_ENABLE_TLSREQUEST=ON
        -DTFDN_ENABLE_WEBREQUEST=ON
        -DTFDN_STATIC_LIBRARY=$(usex static-libs ON OFF)
        -DTFDN_ENABLE_STATIC_LINK=OFF
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install

    # Install pkg-config file
    insinto /usr/$(get_libdir)/pkgconfig
    doins "${BUILD_DIR}/the_Foundation.pc"

    # Remove static library if USE=-static-libs
    if ! use static-libs; then
        rm -f "${ED}"/usr/$(get_libdir)/libthe_Foundation.a
    fi
}
