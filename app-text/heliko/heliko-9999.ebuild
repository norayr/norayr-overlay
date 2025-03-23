EAPI=8

inherit git-r3

DESCRIPTION="Heliko - a Pascal/Lazarus application"
HOMEPAGE="https://github.com/norayr/heliko"
EGIT_REPO_URI="https://github.com/norayr/heliko.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# lazbuild comes with dev-lang/lazarus
DEPEND="dev-lang/lazarus"
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	lazbuild --build-mode=Release heliko.lpi || die "lazbuild failed"
}

src_install() {
	dobin heliko
}
