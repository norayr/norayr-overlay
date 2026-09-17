EAPI=8

inherit multilib

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
	local vocroot="${T}/voc"
	local system_voc="${BROOT%/}/usr/share/voc"
	local libdir="${BROOT%/}/usr/$(get_libdir)"

	mkdir -p "${vocroot}" build || die

	cp -a "${system_voc}/." "${vocroot}/" \
		|| die "failed to prepare writable VOCROOT"

	unset OBERON MODULES
	export VOCROOT="${vocroot}"
	export VOCLIBDIR="${libdir}"

	# Static Oberon libraries must appear after watchcat.c on the
	# final C linker command line.
	export LDFLAGS="${LDFLAGS} -lvoc-pipes -lvoc-time -lvoc-strutils"

	cd build || die

	voc -m ../src/watchcat.Mod \
		|| die "failed to build watchcat"
}

src_install() {
	dobin build/watchcat
	dodoc readme.md
}

