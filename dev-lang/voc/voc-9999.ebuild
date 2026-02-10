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
    local buildroot="${T}/voc"

    if use gcc; then
        export CC=gcc
    elif use clang; then
        export CC=clang
    else
        export CC=tcc
    fi

    # Generate config with sandbox-safe INSTALLDIR
    emake INSTALLDIR="${buildroot}" configuration

    # Ensure config files really contain the sandbox-safe installdir
    sed -i \
        -e "s|^INSTALLDIR[[:space:]]*=[[:space:]]*.*|INSTALLDIR=${buildroot}|" \
        "${S}/Configuration.Make" || die

    sed -i \
        -e "s|^[[:space:]]*installdir\*.*|  installdir*  = '${buildroot}';|" \
        "${S}/Configuration.Mod" || die

    # Now build, again forcing INSTALLDIR because 'full' runs 'configuration'
    emake INSTALLDIR="${buildroot}" full

    if use ocat; then
        local os datamodel compiler
        os=$(awk -F= '/^OS=/{print $2}' "${S}/Configuration.Make")
        datamodel=$(awk -F= '/^DATAMODEL=/{print $2}' "${S}/Configuration.Make")
        compiler=$(awk -F= '/^COMPILER=/{print $2}' "${S}/Configuration.Make")

        local flavour="${os}.${datamodel}.${compiler}"
        local symdir="${S}/build/${flavour}/2"
        local voc="${S}/voc"

        export CFLAGS="-O2 -pipe -I${symdir} -L${symdir}"
        einfo "Building OCatCmd..."
        cd "${symdir}" || die
        "${voc}" -M "../../../src/tools/ocat/OCatCmd.Mod" || die "Failed to build OCatCmd"
        cp OCatCmd "${S}/OCatCmd" || die
    fi
}



src_install() {
  local instdir="/opt/voc"

  # Prevent writes to /etc
  echo -e "#!/bin/sh\nexit 0" > src/tools/make/addlibrary.sh
  chmod +x src/tools/make/addlibrary.sh

    # Use install path for real packaging
    emake INSTALLDIR="${D}${instdir}" install

    # Symlinks
    dosym "${instdir}/bin/voc" /usr/bin/voc
    dosym "${instdir}/bin/showdef" /usr/bin/showdef

    if use ocat; then
        #newbin OCatCmd ocat
        exeinto "${instdir}/bin"
        newexe OCatCmd ocat
        dosym "${instdir}/bin/ocat" /usr/bin/ocat
    fi

    # Environment support
    cat > "${T}/90voc" <<EOF
LDPATH=${instdir}/lib
EOF
    doenvd "${T}/90voc"
}
