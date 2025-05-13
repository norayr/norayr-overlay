EAPI=8

DESCRIPTION="Printer4Lazarus unit for FPC/Lazarus apps"
HOMEPAGE="https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/components/printers"
SRC_URI="https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/main/lazarus-main.tar.gz -> lazarus-main.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"

S="${WORKDIR}/lazarus-main/components/printers"

src_compile() {
	: # nothing to compile
}

src_install() {
	insinto /usr/share/lazarus/components/printer4lazarus
	doins -r *.pas *.pp *.inc *.lpk
}
