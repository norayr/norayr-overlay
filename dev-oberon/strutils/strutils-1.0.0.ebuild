EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="String utility modules for Oberon"
HOMEPAGE="https://github.com/norayr/strutils"
SRC_URI="https://github.com/norayr/strutils/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/voc
"

RDEPEND="
	dev-lang/voc
"

src_compile() {
	mkdir -p build || die
	cd build || die

	voc -s ../src/strTypes.Mod \
		|| die "failed to compile strTypes"

	voc -s ../src/strUtils.Mod \
		|| die "failed to compile strUtils"

	$(tc-getAR) rcs libvoc-strutils.a \
		strTypes.o \
		strUtils.o \
		|| die "failed to create libvoc-strutils.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins \
		build/strTypes.sym \
		build/strUtils.sym

	insinto /usr/share/voc/2/include
	doins \
		build/strTypes.h \
		build/strUtils.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-strutils.a
}

