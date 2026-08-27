# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3

DESCRIPTION="Play images and videos directly in a terminal"
HOMEPAGE="https://github.com/jD91mZM2/termplay"
EGIT_REPO_URI="https://github.com/jD91mZM2/termplay.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/libsixel
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/termplay"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	local myfeatures=(
		bin
	)
	cargo_src_configure --bin termplay
}

pkg_postinst() {
	elog "termplay uses GStreamer plugins at runtime to decode video."
	elog "If a particular format does not play, install the corresponding"
	elog "GStreamer plugin, or use media-plugins/gst-plugins-meta for broad coverage."
}
