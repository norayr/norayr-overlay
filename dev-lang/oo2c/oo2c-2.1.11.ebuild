# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Oberon-2 to C translator and runtime system"
HOMEPAGE="https://ooc.sourceforge.net/"
SRC_URI="
    amd64? ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_64-2.1.11.tar.bz2 -> oo2c-2.1.11-amd64.tar.bz2 )
    x86?   ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-x86.tar.bz2 )
    arm64? ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_64-2.1.11.tar.bz2 -> oo2c-2.1.11-arm64.tar.bz2 )
    arm?   ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-arm.tar.bz2 )
    ppc?   ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-ppc.tar.bz2 )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~ppc"

IUSE="threads doc"

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}"

S="${WORKDIR}/oo2c-2.1.11"


src_prepare() {
    default
    # Clean out leftovers if any
    rm -rf sym obj bin || die
}

src_configure() {
    local myconf=()

    use threads && myconf+=( --enable-threads=pthreads )

    econf "${myconf[@]}"
}

src_compile() {
    # Build the initial bootstrap compiler (stage0)
    emake stage0/oo2c || die "bootstrap compiler failed"

    # Patch Makefile.ext to use C99 standard for stage0 build
    if [[ -f stage0/Makefile.ext ]]; then
        sed -i 's/^CFLAGS =/CFLAGS = -std=gnu99 /' stage0/Makefile.ext || die "Failed to patch CFLAGS"
    else
        die "Makefile.ext not found; cannot patch"
    fi

    # Continue full build
    emake || die "emake failed"
}

src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
