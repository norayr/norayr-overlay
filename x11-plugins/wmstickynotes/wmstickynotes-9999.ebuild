# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Sticky notes app for Window Maker, from GitHub fork"
HOMEPAGE="https://github.com/norayr/wmstickynotes"
EGIT_REPO_URI="https://github.com/norayr/wmstickynotes.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~ppc"
IUSE=""

DEPEND="x11-libs/gtk+:2
	x11-libs/libX11"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	# eapply "${FILESDIR}"/wmstickynotes-0.7-clang16.patch  # Optional
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README
}
