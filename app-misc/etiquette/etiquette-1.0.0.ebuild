EAPI=8

inherit multilib

DESCRIPTION="File tagging utility written in Oberon"
HOMEPAGE="https://github.com/norayr/etiquette"
SRC_URI="https://github.com/norayr/etiquette/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-lang/voc
"

DEPEND="
	dev-oberon/unixfilesystem
	dev-oberon/strutils
	dev-oberon/lists
	dev-oberon/opts
	dev-oberon/xattr
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

	# Static Oberon module libraries.  Dependencies must occur after
	# libraries which use them, so strutils is intentionally last.
	export LDFLAGS="${LDFLAGS} \
		-lvoc-unixfilesystem \
		-lvoc-lists \
		-lvoc-opts \
		-lvoc-xattr \
		-lvoc-strutils"

	cd build || die

	voc -m ../src/tag.Mod \
		|| die "failed to build tag"
}

src_install() {
	dobin build/tag
}

