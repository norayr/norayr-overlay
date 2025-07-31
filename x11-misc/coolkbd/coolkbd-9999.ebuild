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

inherit git-r3 toolchain-funcs

src_prepare() {
    default

    # Use custom config.h from files/
    cp "${FILESDIR}/config.h" config.h || die "failed to copy config.h"
}

src_compile() {
    ./build.sh -release -config config.h -target coolkbd || die "build failed"
}

src_install() {
    dobin coolkbd
    for doc in README README.md README.txt TODO maemo/README; do
        [[ -f ${doc} ]] && dodoc "${doc}"
    done
}

