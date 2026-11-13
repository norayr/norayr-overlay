EAPI=8

inherit git-r3

DESCRIPTION="Gentoo package and filesystem tools written in Free Pascal"
HOMEPAGE="https://github.com/norayr/magnet"
EGIT_REPO_URI="https://github.com/norayr/magnet.git"

LICENSE="GPL-3"
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
	dobin mgnt-get mgnt-pkg mgnt-orphan mgnt-fs-orphan
	dodoc README.md
}
