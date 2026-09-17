EAPI=8

inherit multilib toolchain-funcs

MY_PN="unixFileSystem"

DESCRIPTION="Unix filesystem module for Oberon"
HOMEPAGE="https://github.com/norayr/unixFileSystem"
SRC_URI="https://github.com/norayr/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/voc
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

	cd build || die

	voc -s ../src/UnixFS.Mod \
		|| die "failed to compile UnixFS"

	$(tc-getAR) rcs libvoc-unixfilesystem.a *.o \
		|| die "failed to create libvoc-unixfilesystem.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/*.sym

	insinto /usr/share/voc/2/include
	doins build/*.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-unixfilesystem.a
}
