# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_14 )
inherit python-any-r1 toolchain-funcs

DESCRIPTION="Barev - XMPP flavoured serverless protocol plugin for Pidgin/libpurple"
HOMEPAGE="https://codeberg.org/norayr/barev-purple"
SRC_URI="https://github.com/norayr/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gstreamer +gtk test"
RESTRICT="!test? ( test )"

# Needs pkg-config for plugindir/datadir lookups and for cflags/libs
BDEPEND="
  virtual/pkgconfig
  test? (
    ${PYTHON_DEPS}
    $(python_gen_any_dep 'dev-python/cryptography[${PYTHON_USEDEP}]')
  )
"

# Build-time headers/libs (Makefile uses pkg-config for these).
# When USE=gstreamer we require pidgin itself to be built with the same
# voice/video support, otherwise the calling UI (Conversation menu items,
# call windows) is not present and our media caps go nowhere.
DEPEND="
  dev-libs/glib:2
  dev-libs/libxml2
  >=dev-libs/openssl-1.1.1:0=
  x11-libs/gdk-pixbuf:2[jpeg]
  gtk? ( x11-libs/gtk+:2 )
  gstreamer? (
    net-im/pidgin[gstreamer,v4l]
    media-libs/gstreamer:1.0
    media-libs/gst-plugins-base:1.0
    >=net-libs/farstream-0.2.7:0.2
  )
  !gstreamer? ( net-im/pidgin )
"

pkg_setup() {
  if use test; then
    python_setup
  fi
}

python_check_deps() {
  if use test; then
    python_has_version "dev-python/cryptography[${PYTHON_USEDEP}]"
  fi
}

# plugin needs yggdrasil running
RDEPEND="
  ${DEPEND}
  net-p2p/yggdrasil-go
"

barev_make() {
  emake \
    CC="$(tc-getCC)" \
    PIDGIN_UI=$(usex gtk 1 0) \
    USE_VV=$(usex gstreamer 1 0) "$@"
}

src_compile() {
  barev_make
}

src_test() {
  export GST_PLUGIN_SYSTEM_PATH_1_0="" GST_PLUGIN_PATH_1_0=""
  export GST_REGISTRY_1_0="${T}/gstreamer-registry.bin"
  barev_make PYTHON="${PYTHON}" \
    test-identities test-peer-pins test-parser test-addresses test-images \
    test-formatting test-avatar-cache test-tls test-auth-stream test-auth-protocol test-security-ui
}

src_install() {
  barev_make DESTDIR="${D}" install

  if [[ -e "${ED}"/usr/$(get_libdir)/purple-2/libbarev.so ]]; then
    fperms 0755 /usr/$(get_libdir)/purple-2/libbarev.so
  fi
  dodoc readme.md identity.md images.md
}

pkg_postinst() {
  elog "barev purple plugin installed."
  elog
  elog "To use it:"
  elog "  1) Configure and start Yggdrasil (net-p2p/yggdrasil-go) and ensure you have peers."
  elog "  2) Open Pidgin -> Accounts -> Manage Accounts -> Add."
  elog "  3) Choose protocol 'barev' and pick a nickname."
  elog
  elog "If the protocol does not appear, restart Pidgin."
  elog "  4) Add contacts: nick@ipv6 where ipv6 is their Yggdrasil IP."
  elog
  elog "By default Barev uses 1337 port and 50000-50049 for file transfers."
  elog "Make sure to whitelist those ports if necessary."
  elog "Back up your profile, verify and pin each other's Ed25519 key,"
  elog "then reconnect both accounts to require mutual TLS 1.3 and SASL EXTERNAL."
  elog "Unpinned contacts retain legacy transport without identity authentication."
  use gtk && elog "The conversation information pane shows a shield for authenticated peers; hover for details."
  elog
  elog "Take care!"
}
