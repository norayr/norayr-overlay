EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="List modules for Oberon"
HOMEPAGE="https://github.com/norayr/lists"
SRC_URI="https://github.com/norayr/lists/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
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
	local vocroot="${T}/voc"
	local system_voc="${BROOT%/}/usr/share/voc"
	local libdir="${BROOT%/}/usr/$(get_libdir)"

	mkdir -p "${vocroot}" build || die

	cp -a "${system_voc}/." "${vocroot}/" \
		|| die "failed to prepare writable VOCROOT"

	unset OBERON MODULES
	export VOCROOT="${vocroot}"
	export VOCLIBDIR="${libdir}"

	cd build || die

	voc -s ../src/List.Mod \
		|| die "failed to compile List"

	voc -s ../src/StringList.Mod \
		|| die "failed to compile StringList"

	$(tc-getAR) rcs libvoc-lists.a *.o \
		|| die "failed to create libvoc-lists.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/*.sym

	insinto /usr/share/voc/2/include
	doins build/*.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-lists.a
}

