EAPI=8

DESCRIPTION="Vishap Oberon Compiler"
HOMEPAGE="https://github.com/vishapoberon/compiler"
EGIT_REPO_URI="https://github.com/vishapoberon/compiler.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+gcc clang tcc ocat"

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

IUSE="ocat"

src_compile() {
    emake full

    if use ocat; then
        # Extract platform-specific build flavour
        local os datamodel compiler
        os=$(grep '^OS *=' "${S}/Configuration.Make" | awk -F= '{print $2}' | xargs)
        datamodel=$(grep '^DATAMODEL *=' "${S}/Configuration.Make" | awk -F= '{print $2}' | xargs)
        compiler=$(grep '^COMPILER *=' "${S}/Configuration.Make" | awk -F= '{print $2}' | xargs)

        local flavour="${os}.${datamodel}.${compiler}"
        local symdir="${S}/build/${flavour}/2"
        local voc="${S}/voc"

        export CFLAGS="-O2 -pipe -I${symdir} -L${symdir}"

        cd "${symdir}" || die
        "${voc}" -M -m "${S}/src/tools/ocat/OCatCmd.Mod" || die "Failed to build OCatCmd"
        cd "${OLDPWD}" || die
    fi
}


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

    if use ocat; then
        newbin OCatCmd ocat
    fi

    # Register the library path via env.d
    cat > "${T}/90voc" <<EOF
LDPATH=${instdir}/lib
EOF

    doenvd "${T}/90voc"
}
