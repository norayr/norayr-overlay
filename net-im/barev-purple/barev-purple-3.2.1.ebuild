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

BDEPEND="
  ${PYTHON_DEPS}
  virtual/pkgconfig
  test? (
    sys-apps/dbus
    $(python_gen_any_dep 'dev-python/cryptography[${PYTHON_USEDEP}]')
  )
"

DEPEND="
  >=dev-libs/glib-2.54:2
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
RDEPEND="
  ${DEPEND}
  net-p2p/yggdrasil-go
"

pkg_setup() {
  python_setup
}

python_check_deps() {
  if use test; then
    python_has_version "dev-python/cryptography[${PYTHON_USEDEP}]"
  fi
}

barev_make() {
  emake \
    CC="$(tc-getCC)" PYTHON="${PYTHON}" \
    PIDGIN_UI=$(usex gtk 1 0) \
    USE_VV=$(usex gstreamer 1 0) "$@"
}

src_compile() {
  barev_make
}

src_test() {
  export GST_PLUGIN_SYSTEM_PATH_1_0="" GST_PLUGIN_PATH_1_0=""
  export GST_REGISTRY_1_0="${T}/gstreamer-registry.bin"
  barev_make \
    test-identities test-peer-pins test-parser test-addresses test-images \
    test-formatting test-avatar-cache test-tls test-auth-stream test-auth-protocol \
    test-security-ui test-account-close test-feed-access test-post-store \
    test-post-io test-post-async test-dbus test-dbus-publishing test-dbus-plugin
}

src_install() {
  barev_make DESTDIR="${D}" install

  if [[ -e "${ED}"/usr/$(get_libdir)/purple-2/libbarev.so ]]; then
    fperms 0755 /usr/$(get_libdir)/purple-2/libbarev.so
  fi
  dodoc readme.md CHANGELOG.md identity.md images.md dbus.md \
    feed-access.md post-store.md post-io.md post-async.md
}

pkg_postinst() {
  elog "Restart Pidgin and choose the 'Barev' protocol when adding an account."
  elog "Configure Yggdrasil and add contacts as nick@Yggdrasil-IPv6."
  elog "The default messaging port is TCP 1337; file transfers use TCP 50000-50049."
  elog "Back up your profile, verify and pin each other's Ed25519 key,"
  elog "then reconnect both accounts to require mutual TLS 1.3 and SASL EXTERNAL."
  elog "Unpinned contacts retain legacy transport without identity authentication."
  use gtk && elog "The conversation information pane shows a shield for authenticated peers; hover for details."
  elog "For Insert Image, disable Colorize on the sender and disable Conversation Colors'"
  elog "Ignore incoming format option on the receiver. See images.md for details."
  elog "Remove or move any manually installed ~/.purple/plugins/libbarev.so"
  elog "before starting Pidgin, so it loads the packaged plugin."
}
