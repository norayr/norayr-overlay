EAPI=8

DESCRIPTION="Gentoo package and filesystem tools written in Free Pascal"
HOMEPAGE="https://github.com/norayr/magnet"
SRC_URI="https://github.com/norayr/magnet/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/fpc
"

RDEPEND="
	sys-apps/portage
"

S="${WORKDIR}/${PN}-${PV}"

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
