# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Opinionated C11 library for low-level functionality"
HOMEPAGE="https://git.skyjake.fi/skyjake/the_Foundation"
EGIT_REPO_URI="https://git.skyjake.fi/skyjake/the_Foundation.git"
# Upstream's default branch is typically 'main'
EGIT_BRANCH="main"

LICENSE="BSD-2"
SLOT="0"
# Live ebuilds should not be keyworded
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="debug sse41 static-libs"

# Avoid file collisions with Gentoo's virtual package
# that installs the same headers/libs.
RDEPEND="!dev-libs/tfdn"
DEPEND="
  ${RDEPEND}
  dev-libs/openssl:0=
  dev-libs/libunistring
  sys-libs/zlib
  net-misc/curl
"
BDEPEND="
  virtual/pkgconfig
  dev-vcs/git
"

DOCS=( README.md )

src_prepare() {
  cmake_src_prepare

  # Use system libraries; do not build bundled copies.
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
    # Build shared by default; optional static archive via USE=static-libs
    -DTFDN_STATIC_LIBRARY=$(usex static-libs ON OFF)
    -DTFDN_ENABLE_STATIC_LINK=OFF
  )

  cmake_src_configure
}

src_install() {
  cmake_src_install

  # pkg-config file from the build dir
  insinto /usr/$(get_libdir)/pkgconfig
  doins "${BUILD_DIR}/the_Foundation.pc"

  # Respect USE=static-libs (remove any static archives if disabled)
  if ! use static-libs ; then
    rm -f "${ED}"/usr/$(get_libdir)/libthe_Foundation.a \
          "${ED}"/usr/$(get_libdir)/lib_Foundation.a 2>/dev/null
  fi
}
