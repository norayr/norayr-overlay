# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 desktop

DESCRIPTION="Modern rewrite of Tomboy Notes using FreePascal and Lazarus"
HOMEPAGE="https://github.com/tomboy-notes/tomboy-ng"
EGIT_REPO_URI="https://github.com/tomboy-notes/tomboy-ng.git"
EGIT_COMMIT="v0.42"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-lang/fpc
	dev-lang/lazarus
"
RDEPEND="${DEPEND}"

src_compile() {
	cd source || die

	# Lazarus can't auto-detect, so we export explicitly
	export LAZARUS_DIR="/usr/share/lazarus"

	lazbuild --build-all Tomboy_NG.lpi || die "lazbuild failed"
}

src_install() {
	cd source || die

	# Install binary (name is generated as 'tomboy-ng' despite .lpi name)
	dobin tomboy-ng || die "no binary tomboy-ng found"

	# Install icon and desktop file
	insinto /usr/share/applications
	doins ../glyphs/tomboy-ng.desktop

	insinto /usr/share/pixmaps
	doins ../glyphs/icons/hicolor/256x256/apps/tomboy-ng.png

	dodoc ../README.md
}
