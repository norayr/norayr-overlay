# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Minimal X11 on-screen keyboard"
HOMEPAGE="https://coolbug.org/"
EGIT_REPO_URI="https://repo.coolbug.org/repos/bw/coolkbd.git"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE=""

DEPEND="
    x11-libs/libX11
    x11-libs/libXft
    x11-libs/libXtst
    x11-libs/libXrandr
"
RDEPEND="${DEPEND}"

inherit git-r3

src_prepare() {
    default

    # Use our custom config.h
    eapply_user
    cp "${FILESDIR}/config.h" "${S}"
}

src_compile() {
    emake CC="$(tc-getCC)" coolkbd
}

src_install() {
    dobin coolkbd
    dodoc README* TODO* maemo/README* || true
}


