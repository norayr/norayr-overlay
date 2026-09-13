EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="LCC-derived C cross-compiler for Oric 6502 computers"
HOMEPAGE="https://osdk.org/ https://github.com/Oric-Software-Development-Kit/osdk"
SRC_URI="https://github.com/Oric-Software-Development-Kit/osdk/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"


S="${WORKDIR}/osdk-${PV}"

LICENSE="lcc-1.9 OSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	sys-libs/ncurses:0=
"

RDEPEND="${DEPEND}"


src_compile() {
	append-cflags -std=gnu17

	emake -C osdk/main \
		RELEASE=1 \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		CURSES_LIB="-lncurses"
}

src_install() {
	newbin osdk/main/compiler/compiler osdk-compiler

	dosym osdk-compiler /usr/bin/lcc65
	dosym osdk-compiler /usr/bin/rcc16
}





