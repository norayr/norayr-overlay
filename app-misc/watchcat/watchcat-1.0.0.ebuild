EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Utility combining features of watch and cat"
HOMEPAGE="https://github.com/norayr/watchcat"
SRC_URI="https://github.com/norayr/watchcat/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/voc
"

DEPEND="
	dev-oberon/strutils
	dev-oberon/time
	dev-oberon/pipes
"

RDEPEND="
	dev-lang/voc
"

src_compile() {
	local libdir="${ESYSROOT}/usr/$(get_libdir)"

	mkdir -p build || die
	cd build || die

	# VOC currently expects imported module objects to be available
	# while linking. Extract the packaged module archives locally.
	$(tc-getAR) x "${libdir}/libvoc-strutils.a" \
		|| die "failed to extract strutils"

	$(tc-getAR) x "${libdir}/libvoc-time.a" \
		|| die "failed to extract time"

	$(tc-getAR) x "${libdir}/libvoc-pipes.a" \
		|| die "failed to extract pipes"

	voc -m ../src/watchcat.Mod \
		|| die "failed to build watchcat"
}

src_install() {
	dobin build/watchcat

	if [[ -f readme.md ]]; then
		dodoc readme.md
	elif [[ -f README.md ]]; then
		dodoc README.md
	fi
}

