EAPI=8

inherit toolchain-funcs

DESCRIPTION="LCC-derived C cross-compiler for Oric 6502 computers"
HOMEPAGE="https://osdk.org/ https://github.com/Oric-Software-Development-Kit/osdk"
SRC_URI="https://github.com/Oric-Software-Development-Kit/osdk/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}/osdk-${PV}"

LICENSE="lcc-1.9 OSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_compile() {
	emake -C osdk/main/compiler \
		RELEASE=1 \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -std=gnu17" \
		LDFLAGS="${LDFLAGS}"
}

src_install() {
	newbin osdk/main/compiler/compiler osdk-compiler

	dosym osdk-compiler /usr/bin/lcc65
	dosym osdk-compiler /usr/bin/rcc16
}





