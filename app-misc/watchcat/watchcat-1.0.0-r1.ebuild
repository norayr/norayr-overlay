EAPI=8

inherit multilib

DESCRIPTION="Utility combining features of watch and cat"
HOMEPAGE="https://github.com/norayr/watchcat"
WATCHCAT_COMMIT="8faf27c616ccc2ad9f313d6e72cb8176e1503505"
SRC_URI="https://github.com/norayr/watchcat/archive/${WATCHCAT_COMMIT}.tar.gz -> ${P}-${WATCHCAT_COMMIT}.tar.gz"
S="${WORKDIR}/watchcat-${WATCHCAT_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

BDEPEND="
	>=dev-lang/voc-4.0.0
	test? ( dev-lang/python:* )
"

DEPEND="
	>=dev-lang/voc-4.0.0
	>=dev-oberon/pipes-0.9.0-r2
"

RDEPEND="
	>=dev-lang/voc-4.0.0
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

	# Only pipes remains separate; VOC supplies strutils and clock access.
	# Static Oberon libraries must follow watchcat.c on the linker command line.
	export LDFLAGS="${LDFLAGS} -lvoc-pipes"

	cd build || die

	voc -m ../src/watchcat.Mod \
		|| die "failed to build watchcat"
}

src_test() {
	python3 test/test-timestamps.py "${S}/build/watchcat" \
		|| die "timestamp tests failed"
}

src_install() {
	dobin build/watchcat
	dodoc readme.md
}
