EAPI=8

inherit git-r3

DESCRIPTION="Gentoo package and filesystem tools written in Free Pascal"
HOMEPAGE="https://github.com/norayr/gnt"
EGIT_REPO_URI="https://github.com/norayr/gnt.git"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS=""

BDEPEND="
	dev-lang/fpc
"

RDEPEND="
	sys-apps/portage
"

src_compile() {
	emake
}

src_test() {
	emake test
}

src_install() {
	dobin gnt-get gntpkg gntorphan gntfsorphan
	dodoc README.md
}
