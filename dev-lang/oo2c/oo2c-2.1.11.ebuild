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

IUSE="+gc doc"

DEPEND="
  sys-libs/ncurses
  gc? ( dev-libs/boehm-gc )
"

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

    if use gc; then
        myconf+=( --with-gc )
    else
        myconf+=( --with-gc=no --enable-threads=none )
    fi

    econf "${myconf[@]}"
}



src_compile() {
    # Make makefilegen.pl executable
    chmod +x "${S}"/rsrc/OOC/makefilegen.pl || die "chmod failed"

    # Generate Makefile.ext
    "${S}"/rsrc/OOC/makefilegen.pl > "${S}"/stage0/Makefile.ext || die "makefilegen.pl failed"

    # Create necessary object dirs
    mkdir -p "${S}"/stage0/obj "${S}"/stage0/lib/obj || die "mkdir failed"

    # Compile all .c files into .o to prepare for oo2c_.c
    emake -j1 -f stage0/Makefile.ext stage0/obj/oo2c.c stage0/lib/obj/RT0.o

    # Now generate oo2c_.c (needed for building final stage0 compiler)
    emake -j1 -f stage0/Makefile.ext stage0/obj/oo2c_.c

    # Patch it to include the missing header
    sed -i '1i#include <oo2c.oh>' stage0/obj/oo2c_.c || die "patching oo2c_.c failed"

    # Inject -std=gnu99 into CFLAGS (if not already present)
    sed -i '/^CFLAGS[[:space:]]*=/ s|$| -std=gnu99|' "${S}"/stage0/Makefile.ext || die "patching CFLAGS failed"

    # Finally build the stage0 oo2c binary
    emake -j1 -f stage0/Makefile.ext oo2c
}

src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
