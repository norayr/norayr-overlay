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

src_unpack() {
    default

    case ${ARCH} in
        amd64|arm64)
            S="${WORKDIR}/oo2c_64-2.1.11"
            ;;
        x86|arm)
            S="${WORKDIR}/oo2c_32-2.1.11"
            ;;
        *)
            die "Unknown architecture ${ARCH}"
            ;;
    esac
}



src_prepare() {
    default
    # Clean out leftovers if any
    rm -rf sym obj bin || die
    #sed -i '/^CFLAGS[[:space:]]*=/ s/$/ -std=gnu99/' stage0/Makefile.ext || die "failed to patch Makefile.ext"
}

src_configure() {
    local myconf=()

    use threads && myconf+=( --enable-threads=pthreads )

    econf "${myconf[@]}"
}

src_compile() {
    # Run make up to the point Makefile.ext is generated
    emake -j1 dist

    # Inject -std=gnu99 into generated Makefile
    einfo "Patching stage0/Makefile.ext to add -std=gnu99..."
    sed -i '/^CFLAGS[[:space:]]*=/ s/$/ -std=gnu99/' stage0/Makefile.ext || die "failed to patch stage0 Makefile"

    # Build stage0
    emake -j1 stage0/oo2c
}

src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
