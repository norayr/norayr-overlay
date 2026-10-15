EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Unix pipes module for Oberon"
HOMEPAGE="https://github.com/norayr/pipes"
PIPES_COMMIT="4e766a1ca0260af98428d92e038480a2609f02bd"
SRC_URI="https://github.com/norayr/pipes/archive/${PIPES_COMMIT}.tar.gz -> ${P}-${PIPES_COMMIT}.tar.gz"
S="${WORKDIR}/pipes-${PIPES_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

BDEPEND="
	>=dev-lang/voc-4.0.0
"

DEPEND="
	>=dev-lang/voc-4.0.0
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

	# Do not reuse the symbols or headers of an already-installed pipes.
	rm -f "${vocroot}"/*/sym/pipes.sym \
		"${vocroot}"/*/include/pipes.h \
		|| die "failed to drop the installed package from VOCROOT"

	unset OBERON MODULES
	export VOCROOT="${vocroot}"
	export VOCLIBDIR="${libdir}"

	cd build || die
	voc -s ../src/pipes.Mod || die "failed to compile pipes"
	$(tc-getAR) rcs libvoc-pipes.a pipes.o || die "failed to create libvoc-pipes.a"
}

src_test() {
	cd build || die
	voc -m ../test/testPipes.Mod || die "failed to build pipes test"
	./testPipes || die "pipes test failed"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/pipes.sym
	insinto /usr/share/voc/2/include
	doins build/pipes.h
	insinto "/usr/$(get_libdir)"
	doins build/libvoc-pipes.a
}
