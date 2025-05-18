EAPI=8

inherit git-r3 go-module

DESCRIPTION="Open-source local LLM inference engine with OpenAI-compatible API"
HOMEPAGE="https://github.com/mudler/LocalAI"
EGIT_REPO_URI="https://github.com/mudler/LocalAI.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

DEPEND="dev-lang/go"
RDEPEND="${DEPEND}"

src_unpack() {
    git-r3_src_unpack
    go-module_src_unpack
}

#src_prepare() {
#    default
#    export GOPROXY=off
#}

src_compile() {
    ego build -o local-ai .
}

src_install() {
    dobin local-ai
    dodoc README.md
    keepdir /var/lib/localai/models
}
