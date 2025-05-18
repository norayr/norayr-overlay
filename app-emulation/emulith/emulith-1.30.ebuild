# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="ETH Lilith Modula-2 computer emulator"
HOMEPAGE="http://pascal.hansotten.com/niklaus-wirth/lilith/emulith/"
SRC_URI="
    http://pascal.hansotten.com/uploads/lilith/Emulith_v13.tgz -> ${P}.tgz
    http://pascal.hansotten.com/uploads/lilith/docu/LilithHandbook_Aug82.pdf
    tools? ( 
        http://pascal.hansotten.com/uploads/lilith/ETH_Disks.zip
        http://pascal.hansotten.com/uploads/lilith/medos.zip
        http://pascal.hansotten.com/uploads/lilith/medos_txt.zip
    )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+floppy tools compiler"

RDEPEND="
    x11-libs/fltk:1[opengl]
    x11-libs/libX11
    x11-libs/libXft
    media-libs/libjpeg-turbo
    media-libs/libpng
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
  default

  local fltk_cflags_escaped="-Ifltk"
  local fltk_libdir_escaped="fltk/lib"

  sed -i \
    -e "s|-Ifltk|${fltk_cflags_escaped}|g" \
    -e "s|fltk/lib|${fltk_libdir_escaped}|g" \
    Makefile || die "sed failed"

  # Undefine all b0..b7 before FLTK includes to prevent macro collision
  sed -i '/#include "lilith.h"/a \
#ifdef b0\n#undef b0\n#endif\n\
#ifdef b1\n#undef b1\n#endif\n\
#ifdef b2\n#undef b2\n#endif\n\
#ifdef b3\n#undef b3\n#endif\n\
#ifdef b4\n#undef b4\n#endif\n\
#ifdef b5\n#undef b5\n#endif\n\
#ifdef b6\n#undef b6\n#endif\n\
#ifdef b7\n#undef b7\n#endif' \
    Src/fltk_cde.c || die "sed undef b0-b7 failed"
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

    if use tools; then
        emake fs
    fi
}

src_install() {
    dobin emulith

    if use tools; then
        dobin support/lft support/pp support/dmp || die
    fi

    insinto /usr/share/emulith
    doins -r img mcode ascii.def emulith.ini

    if use floppy; then
        insinto /usr/share/emulith/floppy
        doins floppy/*
    fi

    if use compiler; then
        insinto /usr/share/emulith/compiler
        doins "${DISTDIR}"/ETH_Disks.zip
        doins "${DISTDIR}"/medos*.zip
    fi

    dodoc "${DISTDIR}/LilithHandbook_Aug82.pdf"
    dodoc docu/Emulith_Manual_1.3.pdf docu/18-03-2012.txt

    keepdir /var/lib/emulith
    dosym ../../var/lib/emulith /usr/share/emulith/userdata
}

pkg_postinst() {
    elog "To start the emulator:"
    elog "  \$ emulith"
    elog
    elog "Default disk images are installed to:"
    elog "  /usr/share/emulith/img"
    elog
    elog "Create writable copies in your home directory:"
    elog "  mkdir -p ~/.emulith/img"
    elog "  cp /usr/share/emulith/img/* ~/.emulith/img/"
    elog

    if use compiler; then
        elog "Compiler-related disk images (ETH_Disks.zip, medos.zip) installed in:"
        elog "  /usr/share/emulith/compiler"
    fi
}
