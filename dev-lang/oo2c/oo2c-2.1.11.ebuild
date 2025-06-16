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

    if use gc; then
        myconf+=( --with-gc )
    else
        myconf+=( --disable-gc --enable-threads=none )
    fi

    econf "${myconf[@]}"
}



src_compile() {
    chmod +x "${S}/rsrc/OOC/makefilegen.pl" || die

    # Generate Makefile.ext inside stage0
    einfo "Generating Makefile.ext..."
    cd "${S}/stage0" || die
    "${S}/rsrc/OOC/makefilegen.pl" > Makefile.ext || die "makefilegen.pl failed"
    cd "${S}" || die

    # Make sure necessary object directories exist
    mkdir -p obj lib/obj stage0/obj stage0/lib/obj || die "Failed to create required obj dirs"

# Ensure obj/oo2c_.c exists before patching
if [[ -f "${S}/stage0/obj/oo2c_.c" ]]; then
    einfo "Injecting '#include <oo2c.oh>' into obj/oo2c_.c..."
    grep -q 'oo2c\.oh' "${S}/stage0/obj/oo2c_.c" || \
        sed -i '1i#include <oo2c.oh>' "${S}/stage0/obj/oo2c_.c" || die "Failed to patch obj/oo2c_.c"
else
    ewarn "obj/oo2c_.c not found at patch time; build may fail!"
fi


    # Add gnu99 to CFLAGS
    einfo "Injecting -std=gnu99 into Makefile.ext..."
    sed -i '/^CFLAGS[[:space:]]*=.*$/s/$/ -std=gnu99/' stage0/Makefile.ext || die "Failed to add -std=gnu99"

     if use gc; then
        einfo "Enabling Boehm GC support..."

        # Add -lgc to the link line in Makefile.ext if it's not already there
        if ! grep -q '\-lgc' "${S}/stage0/Makefile.ext"; then
            sed -i '/^oo2c:/s/$/ -lgc/' "${S}/stage0/Makefile.ext" || die "Failed to add -lgc"
        fi
    fi


    # Compile in stage0 directory with correct makefile
    emake -C stage0 -f Makefile.ext oo2c || die "Stage0 compiler build failed"
}



src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
