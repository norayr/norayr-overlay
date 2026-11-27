# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.100.0"
inherit cargo git-r3 multilib multiprocessing toolchain-funcs xdg

DESCRIPTION="Independent web browser written in Rust with a GTK4 interface"
HOMEPAGE="https://nordstjernen.org/ https://github.com/nordstjernen-web/southstar-browser"
EGIT_REPO_URI="https://github.com/nordstjernen-web/southstar-browser.git"
EGIT_BRANCH="main"

# GPL option for the browser; bundled crates retain their own licenses.
LICENSE="GPL-3+ MIT Apache-2.0 BSD BSD-2 ISC MPL-2.0 Unicode-3.0 ZLIB CC0-1.0"
SLOT="0"
KEYWORDS=""
RESTRICT="test"

RDEPEND="
	>=gui-libs/gtk-4.14:4
	>=dev-libs/glib-2.80:2
	>=x11-libs/cairo-1.18
	>=media-libs/harfbuzz-8.3
	>=media-libs/fontconfig-2.15
	media-libs/freetype:2
	media-libs/libepoxy
	dev-libs/openssl:0=
	app-i18n/uchardet
	dev-db/sqlite:3
	sys-libs/libseccomp
	>=media-video/ffmpeg-6:=[opus,vorbis,vpx]
	>=media-libs/libsdl3-3.2
	media-libs/libavif
	app-text/enchant:2
	media-libs/libvorbis
	media-libs/opusfile
	media-libs/libglvnd
	net-misc/publicsuffix-db
	app-misc/ca-certificates
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_unpack() {
    git-r3_src_unpack
    cd "${S}" || die
    cargo_live_src_unpack
}

src_configure() {
	:
}

southstar_xtask() {
	local -x CARGO_NET_OFFLINE=true
	local -x CARGO_BUILD_JOBS="$(makeopts_jobs)"
	local -x PKG_CONFIG="$(tc-getPKG_CONFIG)"
	cargo_env "${CARGO}" xtask "$@" --webgpu disabled || die
}

src_compile() {
	southstar_xtask build
}

src_install() {
	southstar_xtask install --prefix /usr --destdir "${ED}" \
		--libdir "$(get_libdir)"
}
