EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="HexChat-style IRC client written in Free Pascal and Lazarus"
HOMEPAGE="https://github.com/Aruna-Hewapathirane/HexChat-Clone"
EGIT_REPO_URI="https://github.com/Aruna-Hewapathirane/HexChat-Clone.git"
EGIT_BRANCH="main"

LICENSE="MIT"
SLOT="0"
IUSE=""

BDEPEND="
	>=dev-lang/fpc-3.2.0
	dev-lang/lazarus[gui,gtk2]
"
DEPEND="
	dev-libs/openssl:=
	x11-libs/gtk+:2
"
RDEPEND="${DEPEND}"

src_compile() {
	[[ -f irccore.pas ]] ||
		die "Required upstream source file irccore.pas is missing"

	mkdir -p "${T}/lazarus" || die

	lazbuild \
		--pcp="${T}/lazarus" \
		--lazarusdir=/usr/share/lazarus \
		--ws=gtk2 \
		paschat.lpi || die "lazbuild failed"
}

src_install() {
	dobin paschat

	make_desktop_entry \
		paschat \
		"PasChat IRC Client" \
		internet-chat \
		"Network;IRCClient;"

	dodoc README.md
}
