# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
RUST_MIN_VER="1.98.0"

inherit git-r3 multiprocessing python-any-r1 rust toolchain-funcs xdg

DESCRIPTION="Independent web browser with its own web engine"
HOMEPAGE="https://ladybird.org/ https://github.com/LadybirdBrowser/ladybird"
EGIT_REPO_URI="https://github.com/LadybirdBrowser/ladybird.git"
EGIT_BRANCH="master"

# Includes the licenses of bundled runtime dependencies.
LICENSE="BSD-2 BSD MIT Apache-2.0 LGPL-2.1+ MPL-2.0 ISC ZLIB FTL Unicode-3.0"
SLOT="0"
KEYWORDS=""
RESTRICT="test network-sandbox"

RDEPEND="
	>=dev-qt/qtbase-6.10:6[gui,widgets,network,dbus,X,wayland]
	>=dev-qt/qtpositioning-6.10:6
	dev-libs/glib:2
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/libpulse
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/xcb-util-wm
	app-misc/ca-certificates
	media-fonts/liberation-fonts
	!www-client/ladybird-bin
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/cmake-3.30
	dev-build/ninja
	dev-build/autoconf
	dev-build/autoconf-archive
	dev-build/automake
	dev-build/libtool
	dev-lang/nasm
	dev-lang/perl
	dev-util/glslang
	dev-util/patchelf
	dev-vcs/git
	app-arch/unzip
	app-arch/zip
	net-misc/curl
	sys-libs/ncurses
	virtual/pkgconfig
	|| ( >=sys-devel/gcc-14 >=llvm-core/clang-19 )
"

pkg_setup() {
	python-any-r1_pkg_setup
	rust_pkg_setup
}

src_prepare() {
	default

	# The upstream build driver configures CMake using the Release preset.
	# Keep bundled libraries in a private directory rather than /usr/lib*.
	sed -i '/"LADYBIRD_VCPKG_TYPE": "release"/i\        "CMAKE_INSTALL_PREFIX": "/opt/ladybird",\n        "CMAKE_INSTALL_LIBDIR": "lib",\n        "CMAKE_INSTALL_LIBEXECDIR": "libexec",\n        "BUILD_TESTING": "OFF",\n        "LADYBIRD_ENABLE_UPDATE_CHECK": "OFF",' \
		Meta/CMake/presets/CMakeBasePresets.json || die
}

src_configure() {
	:
}

src_compile() {
	# vcpkg and the Rust build download pinned dependencies during the build.
	export CARGO_HOME="${WORKDIR}/cargo-home"
	export VCPKG_MAX_CONCURRENCY="$(makeopts_jobs)"
	"${PYTHON}" Meta/ladybird.py build --preset Release \
		--cc "$(tc-getCC)" --cxx "$(tc-getCXX)" \
		--jobs "$(makeopts_jobs)" || die
}

src_install() {
	local builddir="${S}/Build/release"
	DESTDIR="${D}" cmake --install "${builddir}" \
		--component ladybird_Runtime || die
	DESTDIR="${D}" cmake --install "${builddir}" \
		--component ladybird_SystemIntegration || die
}
