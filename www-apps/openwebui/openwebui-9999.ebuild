EAPI=8

inherit git-r3

DESCRIPTION="Open source web UI for local LLMs (Ollama-compatible)"
HOMEPAGE="https://github.com/open-webui/open-webui"
EGIT_REPO_URI="https://github.com/open-webui/open-webui.git"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
  net-libs/nodejs
  net-libs/pnpm
"
RDEPEND="${DEPEND}"

src_compile() {
    pnpm install
    pnpm run build
}

src_install() {
    insinto /opt/openwebui
    doins -r dist public
    exeinto /opt/openwebui
    doexe start.sh
    dodoc README.md
}

