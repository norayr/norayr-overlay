# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Google Chat plugin for libpurple"
HOMEPAGE="https://github.com/EionRobb/purple-googlechat"
EGIT_REPO_URI="https://github.com/EionRobb/purple-googlechat.git"

LICENSE="GPL-3+"
SLOT="0"
IUSE="pidgin3"

RDEPEND="
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/protobuf-c
	virtual/zlib
	pidgin3? ( net-im/pidgin3:3 )
	!pidgin3? ( net-im/pidgin:0/2 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/protobuf-c
	virtual/pkgconfig
"

src_compile() {
	if use pidgin3; then
		emake libgooglechat3.so
	else
		emake libgooglechat.so
	fi
}

src_install() {
	local pc target plugindir datadir

	if use pidgin3; then
		pc="purple-3"
		target="libgooglechat3.so"
	else
		pc="purple"
		target="libgooglechat.so"
	fi

	# Do not use upstream's auto-detected install paths.  Systems may have
	# both libpurple 2 and libpurple 3 installed, while the USE flag selects
	# exactly which plugin we are packaging.
	plugindir="$(pkg-config --variable=plugindir "${pc}")" || die
	datadir="$(pkg-config --variable=datadir "${pc}")" || die
	[[ -n ${plugindir} ]] || die "Could not determine ${pc} plugin directory"
	[[ -n ${datadir} ]] || die "Could not determine ${pc} data directory"

	insinto "${plugindir}"
	doins "${target}"

	local size
	for size in 16 22 48; do
		insinto "${datadir}/pixmaps/pidgin/protocols/${size}"
		newins "googlechat${size}.png" googlechat.png
	done

	dodoc README.md
}

pkg_postinst() {
	elog "Restart Pidgin if it was running."
	elog "Add an account with protocol 'Google Chat'."
	elog "Authentication uses cookies from a logged-in chat.google.com session."
	elog "Copy the COMPASS, SSID, SID, OSID and HSID cookie values into the"
	elog "account settings as described by upstream, then close that browser window."
	elog "See ${HOMEPAGE}#authentication for the current authentication instructions."
}
