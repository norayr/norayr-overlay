# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Shisen puzzle game using the Helianthus multimedia library"
HOMEPAGE="https://coolbug.org/users/bw/helianthus/"
EGIT_REPO_URI="https://coolbug.org/earthworm/repo/bw/helianthuslab"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE=""  # no use flags

# Build-time tools
BDEPEND="virtual/pkgconfig
         sys-devel/gcc"
# Libraries (build and run-time)
DEPEND="media-libs/libsdl2
        media-libs/sdl2-mixer
        media-libs/sdl2-image
        media-libs/freetype:2
        media-libs/helianthus"
RDEPEND="${DEPEND}"

src_compile() {
    # Compile the single source file using pkg-config to get helianthus flags
    $(tc-getCC) ${CFLAGS} $(pkg-config --cflags helianthus) \
        onefile/shisen.c -o shisen \
        ${LDFLAGS} $(pkg-config --libs helianthus) || die "Compilation failed"
}

src_install() {
    dobin shisen  # Install the binary to /usr/bin
}
