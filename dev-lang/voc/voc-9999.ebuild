EAPI=8

DESCRIPTION="Vishap Oberon Compiler"
HOMEPAGE="https://github.com/vishapoberon/compiler"
EGIT_REPO_URI="https://github.com/vishapoberon/compiler.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+gcc clang tcc"

REQUIRED_USE="^^ ( gcc clang tcc )"

DEPEND="dev-build/make
        gcc?   ( sys-devel/gcc )
        clang? ( sys-devel/clang )
        tcc?   ( dev-lang/tcc )"

RDEPEND="${DEPEND}"

inherit git-r3

src_compile() {
    if use gcc; then
        export CC=gcc
    elif use clang; then
        export CC=clang
    elif use tcc; then
        export CC=tcc
    fi

    export VOC_INSTALLDIR="/opt/voc"
    emake full
}

src_install() {
    local instdir="/opt/voc"

    # Prevent attempts to write to /etc or run ldconfig
    echo -e "#!/bin/sh\nexit 0" > src/tools/make/addlibrary.sh
    chmod +x src/tools/make/addlibrary.sh

    emake INSTALLDIR="${D}${instdir}" install

    # Symlinks
    dosym "${instdir}/bin/voc" /usr/bin/voc
    dosym "${instdir}/bin/showdef" /usr/bin/showdef

    # Register the library path via env.d
    cat > "${T}/90voc" <<EOF
LDPATH=${instdir}/lib
EOF

    doenvd "${T}/90voc"
}
