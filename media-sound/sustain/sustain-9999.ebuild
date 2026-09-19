# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.85.0"

inherit cargo desktop git-r3 xdg

DESCRIPTION="Linux music library manager and player with Pioneer/Rekordbox USB export"
HOMEPAGE="https://github.com/open-sustain/sustain"
EGIT_REPO_URI="https://github.com/open-sustain/sustain.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=gui-libs/gtk-4.18:4
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/libdiscid
"

RDEPEND="${DEPEND}
	media-libs/gst-plugins-good:1.0
	media-libs/gst-plugins-bad:1.0
"

BDEPEND="
	virtual/pkgconfig
	llvm-core/clang
"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	cargo_src_configure --package sustain-app
}

src_compile() {
	cargo_src_compile
}

src_install() {
	dobin "$(cargo_target_dir)"/release/sustain

	domenu data/io.github.open_sustain.sustain.desktop

	insinto /usr/share/metainfo
	doins data/io.github.open_sustain.sustain.metainfo.xml

	local size
	for size in 16 24 32 48 64 128 256 512 ; do
		newicon -s "${size}" \
			"data/icons/hicolor/${size}x${size}/apps/io.github.open_sustain.sustain.png" \
			io.github.open_sustain.sustain.png
	done

	insinto /usr/share/icons/hicolor/scalable/actions
	doins data/icons/hicolor/scalable/actions/sustain-statistics-symbolic.svg

	dodoc README.md THIRD-PARTY-LICENSES.md
	dodoc crates/dsp/PROVENANCE.md
}

