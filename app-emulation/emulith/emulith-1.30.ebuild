# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="ETH Lilith Modula-2 computer emulator"
HOMEPAGE="http://pascal.hansotten.com/niklaus-wirth/lilith/emulith/"
SRC_URI="
    http://pascal.hansotten.com/uploads/lilith/Emulith_v13.tgz -> ${P}.tgz
    http://pascal.hansotten.com/uploads/lilith/docu/LilithHandbook_Aug82.pdf
"

LICENSE="GPL-2"  # Verify actual license from source
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+floppy"

RDEPEND="
    x11-libs/fltk:1[opengl]
    x11-libs/libX11
    x11-libs/libXft
    media-libs/libjpeg-turbo
    media-libs/libpng
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/emulith"

src_prepare() {
    default

    # Fix FLTK include path in Makefile
    sed -i \
        -e "s|-Ifltk|$(fltk-config --cflags)|g" \
        -e "s|fltk/lib|$(fltk-config --libdir)|g" \
        Makefile || die "sed failed"

    # Fix hardcoded paths in source code
    sed -i \
        -e "s|img/|/usr/share/emulith/img/|g" \
        -e "s|mcode/|/usr/share/emulith/mcode/|g" \
        Src/fltk_cde.c || die "sed failed"
}

src_compile() {
    append-cxxflags $(fltk-config --cxxflags)
    append-ldflags $(fltk-config --ldflags)

    emake lin \
        CXX="$(tc-getCXX)" \
        CC="$(tc-getCC)" \
        STRIP=true \
        CFLAGS="${CFLAGS}" \
        CXXFLAGS="${CXXFLAGS}"
}

src_install() {
    dobin emulith

    insinto /usr/share/emulith
    doins -r img mcode ascii.def emulith.ini

    # Install documentation
    dodoc "${DISTDIR}/LilithHandbook_Aug82.pdf"
    dodoc docu/Emulith_Manual_1.3.pdf docu/18-03-2012.txt

    # Install floppy images if requested
    if use floppy; then
        insinto /usr/share/emulith/floppy
        doins floppy/*
    fi

    # Create symlink for user data
    keepdir /var/lib/emulith
    dosym ../../var/lib/emulith /usr/share/emulith/userdata
}

pkg_postinst() {
    elog "To start the emulator:"
    elog "  $ emulith"
    elog
    elog "Disk images are located in /usr/share/emulith/img"
    elog "User-created files should be stored in ~/.emulith/"
    elog
    elog "You may need to copy disk images to ~/.emulith/img to modify them:"
    elog "  mkdir -p ~/.emulith/img"
    elog "  cp /usr/share/emulith/img/* ~/.emulith/img/"
}
