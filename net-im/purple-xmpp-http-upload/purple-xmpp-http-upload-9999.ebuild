EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="libpurple plugin: XMPP HTTP File Upload for jabber/prpl-jabber"
HOMEPAGE="https://github.com/norayr/purple-xmpp-http-upload"
EGIT_REPO_URI="https://github.com/norayr/purple-xmpp-http-upload.git"

# Adjust if upstream clarifies a license
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

BDEPEND="virtual/pkgconfig"
DEPEND="
  dev-libs/glib:2
  dev-libs/libxml2
  net-im/pidgin
"
RDEPEND="${DEPEND}"

src_compile() {
  # IMPORTANT: don't pass CFLAGS/LDFLAGS on the command line,
  # so Makefile's `CFLAGS += ...` with pkg-config is honored.
  emake CC="$(tc-getCC)" V=1
}

src_install() {
  emake DESTDIR="${D}" install
  dodoc README.md LICENSE || die
}

pkg_postinst() {
  elog "Installed jabber_http_file_upload.so into libpurple's plugindir."
  elog "Restart Pidgin/Finch (or your libpurple client) to load the plugin."
}
