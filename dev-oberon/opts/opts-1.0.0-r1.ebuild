EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Command-line option handling modules for Oberon"
HOMEPAGE="https://github.com/norayr/opts"
SRC_URI="https://github.com/norayr/opts/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

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

	# Drop this package from the copied VOC tree so voc cannot reuse
	# stale symbols/headers from an already-installed older revision.
	rm -f "${vocroot}"/*/sym/optsos.sym "${vocroot}"/*/sym/opts.sym \
		"${vocroot}"/*/include/optsos.h "${vocroot}"/*/include/opts.h \
		|| die "failed to drop the installed package from VOCROOT"

	unset OBERON MODULES
	export VOCROOT="${vocroot}"
	export VOCLIBDIR="${libdir}"

	cd build || die

	voc -s ../src/optsos.Mod \
		|| die "failed to compile optsos"

	voc -s ../src/opts.Mod \
		|| die "failed to compile opts"

	$(tc-getAR) rcs libvoc-opts.a *.o \
		|| die "failed to create libvoc-opts.a"
}

src_install() {
	insinto /usr/share/voc/2/sym
	doins build/*.sym

	insinto /usr/share/voc/2/include
	doins build/*.h

	insinto "/usr/$(get_libdir)"
	doins build/libvoc-opts.a
}
