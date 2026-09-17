EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Time utility module for Oberon"
HOMEPAGE="https://github.com/norayr/time"
SRC_URI="https://github.com/norayr/time/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

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

	voc -s ../src/time.Mod || die "failed to compile time"

	$(tc-getAR) rcs libvoc-time.a time.o \
		|| die "failed to create libvoc-time.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/time.sym

	insinto /usr/share/voc/2/include
	doins build/time.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-time.a
}

