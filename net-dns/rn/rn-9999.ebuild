# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 systemd

DESCRIPTION="Small DNS server for *.v6.alt names with upstream forwarding"
HOMEPAGE="https://github.com/norayr/rn"
EGIT_REPO_URI="https://github.com/norayr/rn.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="systemd"

DEPEND="
	dev-lang/fpc
	dev-build/make
"
RDEPEND=""
BDEPEND=""

src_compile() {
	emake
}

src_install() {
	# Base install (binary + config + docs)
	emake DESTDIR="${D}" install

	# OpenRC script
	emake DESTDIR="${D}" install-openrc

	# Optional systemd
	if use systemd; then
		emake DESTDIR="${D}" install-systemd
	fi

	einstalldocs
}

pkg_postinst() {
	elog "Example startup:"
	elog "  rc-service rn start"
	elog
	elog "The default config file is installed as /etc/rn.conf"
	if use systemd; then
		elog
		elog "If you use systemd, the unit file was also installed."
	fi
}

