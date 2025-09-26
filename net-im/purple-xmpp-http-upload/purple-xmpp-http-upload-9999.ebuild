# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="libpurple (Pidgin) plugin: XMPP HTTP File Upload for jabber/prpl-jabber"
HOMEPAGE="https://github.com/norayr/purple-xmpp-http-upload"
EGIT_REPO_URI="https://github.com/norayr/purple-xmpp-http-upload.git"

# Repo doesn't clearly state a license; adjust if you add one to upstream.
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE=""

# Uses pkg-config and xml2-config during build
BDEPEND="
	virtual/pkgconfig
"

# glib-2 provides gio-2.0 as well
# libpurple is provided by net-im/pidgin (exports purple.pc and plugindir)
DEPEND="
	dev-libs/glib:2
	dev-libs/libxml2
	net-im/pidgin
"
RDEPEND="${DEPEND}"

src_compile() {
	# Respect user CFLAGS/LDFLAGS and use Gentoo toolchain
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}"
}

src_install() {
	# Upstream Makefile honors DESTDIR and installs into purple's plugindir
	emake DESTDIR="${D}" install

	dodoc README.md || die
}

pkg_postinst() {
	elog "Installed jabber_http_file_upload.so into libpurple's plugin directory."
	elog "Restart Pidgin/Finch (or your libpurple client) to load the plugin."
}
