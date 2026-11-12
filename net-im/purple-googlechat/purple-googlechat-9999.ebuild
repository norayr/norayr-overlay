# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Google Chat protocol plugin for Pidgin/libpurple 2"
HOMEPAGE="https://github.com/EionRobb/purple-googlechat"
EGIT_REPO_URI="https://github.com/EionRobb/purple-googlechat.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
PROPERTIES="live"

RDEPEND="
	>=net-im/pidgin-2.14:0=
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/protobuf-c:=
	sys-libs/zlib
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/protobuf
	dev-libs/protobuf-c
	virtual/pkgconfig
"

src_compile() {
	# Upstream auto-selects libpurple 3 when both versions are present.
	# Explicitly build the libpurple 2 module for GTK2 Pidgin.
	emake CC="$(tc-getCC)" libgooglechat.so
}

src_install() {
	local plugindir size
	plugindir="$(pkg-config --variable=plugindir purple)" || die
	[[ -n ${plugindir} ]] || die "Unable to find libpurple 2 plugin directory"

	exeinto "${plugindir}"
	doexe libgooglechat.so

	for size in 16 22 48; do
		insinto "/usr/share/pixmaps/pidgin/protocols/${size}"
		newins "googlechat${size}.png" googlechat.png
	done
}

pkg_postinst() {
	elog "Restart Pidgin, then add an account with protocol Google Chat."
	elog "Authentication needs COMPASS, SSID, SID, OSID and HSID cookies."
	elog "See ${HOMEPAGE}#authentication"
}
