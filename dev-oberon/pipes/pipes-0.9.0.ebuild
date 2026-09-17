EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Unix pipes module for Oberon"
HOMEPAGE="https://github.com/norayr/pipes"
SRC_URI="https://github.com/norayr/pipes/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/voc
"

DEPEND="
	dev-oberon/strutils
"

RDEPEND="
	dev-lang/voc
	dev-oberon/strutils
"

src_compile() {
	mkdir -p build || die
	cd build || die

	voc -s ../src/pipes.Mod \
		|| die "failed to compile pipes"

	$(tc-getAR) rcs libvoc-pipes.a pipes.o \
		|| die "failed to create libvoc-pipes.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/pipes.sym

	insinto /usr/share/voc/2/include
	doins build/pipes.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-pipes.a
}

