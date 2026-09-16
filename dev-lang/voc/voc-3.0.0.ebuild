EAPI=8

DESCRIPTION="Vishap Oberon Compiler"
HOMEPAGE="https://github.com/vishapoberon/compiler"
SRC_URI="https://github.com/vishapoberon/compiler/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/compiler-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+gcc clang tcc ocat"

REQUIRED_USE="^^ ( gcc clang tcc )"

BDEPEND="
    dev-build/make
    gcc?   ( sys-devel/gcc )
    clang? ( sys-devel/clang )
    tcc?   ( dev-lang/tcc )
"

inherit multilib

src_compile() {
    local libdir="/usr/$(get_libdir)"

    if use gcc; then
        export CC=gcc
    elif use clang; then
        export CC=clang
    else
        export CC=tcc
    fi

    # Build the compiler, libraries, and confidence tests without root access.
    emake -j1 PREFIX=/usr LIBDIR="${libdir}"

    if use ocat; then
        local os datamodel compiler flavour symdir
        os=$(awk -F= '/^OS=/{print $2}' Configuration.Make) || die
        datamodel=$(awk -F= '/^DATAMODEL=/{print $2}' Configuration.Make) || die
        compiler=$(awk -F= '/^COMPILER=/{print $2}' Configuration.Make) || die
        flavour="${os}.${datamodel}.${compiler}"
        symdir="${S}/build/${flavour}/2"

        export CFLAGS="-O2 -pipe -I${symdir} -L${symdir}"
        cd "${symdir}" || die
        "${S}/voc" -M "../../../src/tools/ocat/OCatCmd.Mod" || die "Failed to build OCatCmd"
        cp OCatCmd "${S}/OCatCmd" || die "Failed to copy OCatCmd"
    fi
}

src_install() {
    local libdir="/usr/$(get_libdir)"

    # DESTDIR stages files while the compiler retains its final runtime paths.
    emake -j1 PREFIX=/usr LIBDIR="${libdir}" DESTDIR="${D}" install

    if use ocat; then
        newbin "${S}/OCatCmd" ocat
    fi
}
