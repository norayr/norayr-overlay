EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Extended attribute module for Oberon"
HOMEPAGE="https://github.com/norayr/xattr"
SRC_URI="https://github.com/norayr/xattr/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

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

	voc -s ../src/xattr.Mod \
		|| die "failed to compile xattr"

	$(tc-getAR) rcs libvoc-xattr.a *.o \
		|| die "failed to create libvoc-xattr.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/*.sym

	insinto /usr/share/voc/2/include
	doins build/*.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-xattr.a
}
