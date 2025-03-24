# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sticky notes app for window maker"
HOMEPAGE="https://github.com/norayr/wmstickynotes"
EGIT_REPO_URI="https://github.com/norayr/wmstickynotes.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="x11-libs/gtk+:2
	x11-libs/libX11"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	# Apply any local patches if needed
	# eapply "${FILESDIR}"/wmstickynotes-0.7-clang16.patch
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README
}
