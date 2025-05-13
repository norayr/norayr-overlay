# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 desktop

DESCRIPTION="Modern rewrite of Tomboy Notes using FreePascal and Lazarus"
HOMEPAGE="https://github.com/tomboy-notes/tomboy-ng"
SRC_URI=""
EGIT_REPO_URI="https://github.com/tomboy-notes/tomboy-ng.git"
EGIT_COMMIT="v0.36"

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
  # Tomboy-ng uses lazbuild; default Lazarus compiler
  lazbuild --build-all tomboy-ng.lpi || die "lazbuild failed"
}

src_install() {
  # Install binary
  dobin tomboy-ng

  # Install icon and .desktop
  insinto /usr/share/applications
  doins packaging/linux/tomboy-ng.desktop

  insinto /usr/share/pixmaps
  doins packaging/linux/tomboy-ng.png

  # Install docs
  dodoc README.md
}

