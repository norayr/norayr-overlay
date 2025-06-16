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

IUSE="gc doc"

RDEPEND="
  sys-libs/ncurses
  gc? ( dev-libs/boehm-gc )
"
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

econf \
    $(use_enable gc) \
    $(usev !gc && echo "--disable-gc")


    econf "${myconf[@]}"
}



src_compile() {
    chmod +x "${S}/rsrc/OOC/makefilegen.pl" || die "makefilegen.pl not executable"

    einfo "Generating stage0/Makefile.ext..."
    "${S}/rsrc/OOC/makefilegen.pl" > stage0/Makefile.ext || die "Makefile.ext generation failed"

    einfo "Injecting -std=gnu99 into stage0/Makefile.ext..."
    sed -i '/^CFLAGS[[:space:]]*=/ s/$/ -std=gnu99/' stage0/Makefile.ext || die "CFLAGS patch failed"

    if use gc; then
        einfo "Injecting -lgc and -L/usr/lib64..."
        grep -q '\-lgc' stage0/Makefile.ext || \
            sed -i '/^oo2c[[:space:]]*:/ s/$/ -lgc/' stage0/Makefile.ext || die "Failed to patch -lgc"
        sed -i '/^LDFLAGS[[:space:]]*=/ s|$| -L/usr/lib64|' stage0/Makefile.ext || echo 'LDFLAGS += -L/usr/lib64' >> stage0/Makefile.ext
    fi

    einfo "Patching obj/oo2c_.c to include <oo2c.oh>..."
    if [[ -f obj/oo2c_.c ]]; then
        echo '#include <oo2c.oh>' | cat - obj/oo2c_.c > obj/oo2c_.c.tmp && \
        mv obj/oo2c_.c.tmp obj/oo2c_.c || die "Failed to patch obj/oo2c_.c"
    fi

    einfo "Building stage0/oo2c..."
    emake -j1 -f stage0/Makefile.ext oo2c || die "stage0/oo2c build failed"

    einfo "Generating Makefile.ext for final build..."
    "${S}/rsrc/OOC/makefilegen.pl" > Makefile.ext || die "Makefile.ext generation failed"

    einfo "Injecting build flags into final Makefile.ext..."
    sed -i '/^CFLAGS[[:space:]]*=/ s/$/ -std=gnu99/' Makefile.ext || die "CFLAGS patch failed"
    if use gc; then
        grep -q '\-lgc' Makefile.ext || \
            sed -i '/^oo2c[[:space:]]*:/ s/$/ -lgc/' Makefile.ext || die "Failed to patch -lgc"
        sed -i '/^LDFLAGS[[:space:]]*=/ s|$| -L/usr/lib64|' Makefile.ext || echo 'LDFLAGS += -L/usr/lib64' >> Makefile.ext
    fi
   einfo "Patching obj/oo2c_.c to include <oo2c.oh>..."
    mkdir -p obj || die "failed to create obj directory"
    if [[ -f obj/oo2c_.c ]]; then
        echo '#include <oo2c.oh>' | cat - obj/oo2c_.c > obj/oo2c_.c.tmp && \
        mv obj/oo2c_.c.tmp obj/oo2c_.c || die "Failed to patch obj/oo2c_.c"
    fi

    einfo "Building stage0/oo2c..."
    emake -j1 -f stage0/Makefile.ext oo2c || die "stage0/oo2c build failed"

    einfo "Building final oo2c binary..."
    emake -j1 -f Makefile.ext || die "Final build failed"
}





src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
