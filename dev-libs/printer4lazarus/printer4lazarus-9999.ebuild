EAPI=8

inherit git-r3

DESCRIPTION="Printer4Lazarus package for Lazarus (printer abstraction layer)"
HOMEPAGE="https://www.lazarus-ide.org/"
EGIT_REPO_URI="https://gitlab.com/freepascal.org/lazarus/lazarus.git"
EGIT_BRANCH="main"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE=""

src_prepare() {
  default
  cd components/printers || die
}

src_install() {
  insinto /usr/share/lazarus/components/printer4lazarus
  doins -r components/printers/*
}

