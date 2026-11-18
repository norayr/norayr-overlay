# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_14 )
inherit flag-o-matic git-r3 python-any-r1 toolchain-funcs

DESCRIPTION="Oberon Barev serverless messaging plugin for Pidgin over Yggdrasil"
HOMEPAGE="https://github.com/norayr/barev-purple-oberon"
EGIT_REPO_URI="https://github.com/norayr/${PN}.git"
EGIT_BRANCH="main"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="+gtk test"
# The privately linked VOC archive includes XMPP code with unconfirmed licensing.
RESTRICT="mirror bindist !test? ( test )"

DEPEND="
	dev-libs/glib:2
	net-im/pidgin:0
	gtk? ( x11-libs/gtk+:2 )
"
RDEPEND="
	${DEPEND}
	net-p2p/yggdrasil-go
"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/make-4.3
	>=dev-lang/voc-5.3.0[network]
	virtual/pkgconfig
	test? ( $(python_gen_any_dep 'dev-python/cryptography[${PYTHON_USEDEP}]') )
"

python_check_deps() {
	if use test; then
		python_has_version "dev-python/cryptography[${PYTHON_USEDEP}]"
	fi
}

src_configure() {
	tc-export CC PKG_CONFIG
	filter-lto
	unset OBERON MODULES VOCROOT VOCLIBDIR VOC_MODULE_PATH VOC_SYM_PATH VOC_RUNPATH
}

barev_make() {
	emake CC="${CC}" PKG_CONFIG="${PKG_CONFIG}" PYTHON="${PYTHON}" \
		PIDGIN_UI="$(usex gtk 1 0)" \
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
	barev_make test protocol-test protocol-address-test tls-test auth-test auth-protocol-test
}

src_install() {
	barev_make DESTDIR="${D}" install
	dodoc addresses.md identity.md images.md changes.md testing.md
}

pkg_postinst() {
	elog "Restart Pidgin and choose the 'VOC Barev' protocol when adding an account."
	elog "Add contacts as nick@Yggdrasil-IPv6 or nick@<encoded>.barev.v6.alt."
	elog "Rejected additions on connected accounts are removed and report a specific reason."
	elog "Get Info shows both address forms; Accounts -> your account -> My Barev address"
	elog "shows your own full encoded address for sharing. Conversion needs no DNS server."
	elog "Back up your profile before testing. Exchange and verify Ed25519 keys,"
	elog "pin each other's key through Peer identity, then reconnect both accounts."
	elog "Pinned connections require mutual TLS 1.3 and SASL EXTERNAL; unpinned contacts use legacy transport."
	use gtk && elog "The conversation information pane shows a lock only for a live authenticated peer connection."
	elog "The default messaging port is TCP 1337; file transfers use TCP 50000-50049."
	elog "Listeners bind to the selected local Yggdrasil address."
	elog "Use Insert -> Image in a conversation to send PNG/JPEG pictures."
	elog "Picture processing uses VOC's native codecs and memory-only files."
	elog "Large pictures offer Fit for chat, Send original, or Cancel."
	elog "Advanced account settings control resizing and automatic image acceptance."
	elog "If C Barev is enabled at the same time, give the accounts different local ports."
	elog "Remove or move any manually installed ~/.purple/plugins/libvoc-barev.so"
	elog "before starting Pidgin, so it loads the packaged plugin."
}
