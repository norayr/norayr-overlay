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
    # Make sure the makefile generator is executable
    chmod +x rsrc/OOC/makefilegen.pl || die

    # Generate stage0 Makefile
    einfo "Generating stage0/Makefile.ext..."
    rsrc/OOC/makefilegen.pl > stage0/Makefile.ext || die "makefilegen.pl failed"

    # Patch Makefile.ext to use C99
    sed -i '/^CFLAGS[[:space:]]*=/ s/$/ -std=gnu99/' stage0/Makefile.ext || die "CFLAGS patch failed"

    # Create required directories
    mkdir -p obj stage0/obj stage0/lib/obj || die "failed to create build directories"

    # Generate obj/oo2c_.c via setup
    einfo "Building stage0/oo2c_setup to generate obj/oo2c_.c..."
    emake -j1 -f stage0/Makefile.ext stage0/oo2c_setup || die "oo2c_setup failed"

    # Patch the generated source
    if [[ -f obj/oo2c_.c ]]; then
        einfo "Patching obj/oo2c_.c to include <oo2c.oh>..."
        echo '#include <oo2c.oh>' | cat - obj/oo2c_.c > obj/oo2c_.c.patched || die
        mv obj/oo2c_.c.patched obj/oo2c_.c || die
    else
        die "obj/oo2c_.c was not generated"
    fi

    # Compile the full compiler binary
    einfo "Compiling oo2c..."
    emake -j1 -f stage0/Makefile.ext oo2c || die "oo2c compile failed"
}





src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    # Optional doc files
    dodoc AUTHORS ChangeLog NEWS README* || die
}
