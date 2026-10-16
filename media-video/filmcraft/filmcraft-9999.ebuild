# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

inherit cargo desktop git-r3

DESCRIPTION="Nonlinear video editor written in Rust"
HOMEPAGE="https://getartcraft.com/apps/${PN} https://github.com/storytold/${PN}"
EGIT_REPO_URI="https://github.com/storytold/${PN}.git"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""
IUSE="+cli"
RESTRICT="test"

DEPEND="
	dev-libs/wayland
	media-libs/vulkan-loader
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	media-libs/alsa-lib
"
RDEPEND="${DEPEND}"
BDEPEND="dev-util/pkgconf"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	local packages=( -p "${PN}" )
	use cli && packages+=( -p "${PN}-cli" )
	cargo_src_configure "${packages[@]}" --frozen
}

src_install() {
	dobin "$(cargo_target_dir)/${PN}"
	if use cli; then
		dobin "$(cargo_target_dir)/${PN}-cli"
	fi

	make_desktop_entry "${PN}" "FilmCraft" "${PN}" "AudioVideo;Video;VideoEditor;"
	einstalldocs
}
