# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Google Chat plugin for libpurple"
HOMEPAGE="https://github.com/EionRobb/purple-googlechat"
EGIT_REPO_URI="https://github.com/EionRobb/purple-googlechat.git"

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/protobuf-c
	net-im/pidgin
	virtual/zlib
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/protobuf-c
	virtual/pkgconfig
"

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.md
}

pkg_postinst() {
	elog "Restart Pidgin if it was running, then add a Google Chat account."
	elog "Authentication uses cookies from a logged-in chat.google.com session."
	elog "Copy the COMPASS, SSID, SID, OSID and HSID cookie values into the"
	elog "Advanced tab of the account, then close that browser window."
	elog "See ${HOMEPAGE}#authentication for the current authentication instructions."
}
