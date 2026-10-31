# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_14 )
inherit flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Oberon Barev serverless messaging plugin for Pidgin over Yggdrasil"
HOMEPAGE="https://github.com/norayr/barev-purple-oberon"
SRC_URI="https://github.com/norayr/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
# The privately linked VOC archive includes XMPP code with unconfirmed licensing.
RESTRICT="mirror bindist !test? ( test )"

DEPEND="
	dev-libs/glib:2
	net-im/pidgin:0
	x11-libs/gdk-pixbuf:2[jpeg]
"
RDEPEND="
	${DEPEND}
	net-p2p/yggdrasil-go
"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/make-4.3
	>=dev-lang/voc-4.0.4[network]
	virtual/pkgconfig
"

src_configure() {
	tc-export CC PKG_CONFIG
	filter-lto
	unset OBERON MODULES VOCROOT VOCLIBDIR
}

barev_make() {
	emake CC="${CC}" PKG_CONFIG="${PKG_CONFIG}" PYTHON="${PYTHON}" \
		CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
		PLUGINDIR="${EPREFIX}/usr/$(get_libdir)/purple-2" \
		DATADIR="${EPREFIX}/usr/share" "$@"
}

src_compile() {
	barev_make plugin
}

src_test() {
	# Keep libpurple's optional media probing away from host devices.
	export GST_PLUGIN_SYSTEM_PATH_1_0="" GST_PLUGIN_PATH_1_0=""
	export GST_REGISTRY_1_0="${T}/gstreamer-registry.bin"
	barev_make test protocol-test
}

src_install() {
	barev_make DESTDIR="${D}" install
	dodoc addresses.md images.md
}

pkg_postinst() {
	elog "Restart Pidgin and choose the 'VOC Barev' protocol when adding an account."
	elog "Add contacts as nick@Yggdrasil-IPv6 or nick@<encoded>.barev.v6.alt."
	elog "Get Info shows both address forms; Accounts -> your account -> My Barev address"
	elog "shows your own full encoded address for sharing. Conversion needs no DNS server."
	elog "The default messaging port is TCP 1337; file transfers use TCP 50000-50049."
	elog "Listeners bind to the selected local Yggdrasil address."
	elog "Use Insert -> Image in a conversation to send PNG/JPEG pictures."
	elog "Large pictures offer Fit for chat, Send original, or Cancel."
	elog "Advanced account settings control resizing and automatic image acceptance."
	elog "If C Barev is enabled at the same time, give the accounts different local ports."
	elog "Remove or move any manually installed ~/.purple/plugins/libvoc-barev.so"
	elog "before starting Pidgin, so it loads the packaged plugin."
}
