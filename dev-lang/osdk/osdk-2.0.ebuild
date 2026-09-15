EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Software development kit and cross-development tools for Oric computers"
HOMEPAGE="https://osdk.org/ https://github.com/Oric-Software-Development-Kit/osdk"
SRC_URI="https://github.com/Oric-Software-Development-Kit/osdk/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

PATCHES=(
	"${FILESDIR}/${P}-taptool-fgets.patch"
	"${FILESDIR}/${P}-tap2cd-fgets.patch"
)

S="${WORKDIR}/osdk-${PV}"

LICENSE="lcc-1.9 OSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	sys-libs/ncurses:0=
	media-libs/freeimage
"

RDEPEND="${DEPEND}"

src_prepare() {
	sed -i 's/\r$//' \
		osdk/main/TapTool/sources/TapTool.cpp \
		osdk/main/tap2cd/sources/tap2cd.c || die

	default
}

src_compile() {
	append-cflags -std=gnu17

	emake -C osdk/main \
		RELEASE=1 \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		CURSES_LIB="-lncurses" \
		CXXSTD="-std=c++20"
}

src_install() {
	newbin osdk/main/compiler/compiler osdk-compiler

	dosym osdk-compiler /usr/bin/lcc65
	dosym osdk-compiler /usr/bin/rcc16
}





