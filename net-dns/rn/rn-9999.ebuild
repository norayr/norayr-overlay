# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 systemd

DESCRIPTION="Small DNS server for *.v6.alt names with upstream forwarding"
HOMEPAGE="https://github.com/norayr/rn"
EGIT_REPO_URI="https://github.com/norayr/rn.git"

# Set this after you add a LICENSE file to the repo.
LICENSE="|| ( MIT GPL-2 GPL-3 BSD )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

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
	dosbin rn
	insinto /etc
	doins conf/rn.conf

	systemd_dounit conf/rn.service
	newinitd conf/rn.openrc rn

	dodoc readme.md
	#dobin test_vectors.sh
}


