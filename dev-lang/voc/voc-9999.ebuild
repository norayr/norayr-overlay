EAPI=8

DESCRIPTION="Vishap Oberon Compiler"
HOMEPAGE="https://github.com/vishapoberon/compiler"
EGIT_REPO_URI="https://github.com/vishapoberon/compiler.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+gcc clang tcc"

REQUIRED_USE="^^ ( gcc clang tcc )"

DEPEND="sys-devel/make
        gcc?   ( sys-devel/gcc )
        clang? ( sys-devel/clang )
        tcc?   ( dev-lang/tcc )"

RDEPEND="${DEPEND}"

inherit git-r3

src_compile() {
    if use gcc; then
        export CC=gcc
        export VOC_INSTALLDIR="/opt/voc-gcc"
    elif use clang; then
        export CC=clang
        export VOC_INSTALLDIR="/opt/voc-clang"
    elif use tcc; then
        export CC=tcc
        export VOC_INSTALLDIR="/opt/voc-tcc"
    fi

    emake full
}

src_install() {
    local instdir
    if use gcc; then
        instdir="/opt/voc-gcc"
    elif use clang; then
        instdir="/opt/voc-clang"
    elif use tcc; then
        instdir="/opt/voc-tcc"
    fi

    # Tell the Makefile to install into the sandboxed image directory
    emake INSTALLDIR="${D}${instdir}" install

    dosym "${instdir}/bin/voc" /usr/bin/voc
    dosym "${instdir}/bin/showdef" /usr/bin/showdef
}
