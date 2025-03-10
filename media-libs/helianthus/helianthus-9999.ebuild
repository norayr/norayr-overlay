# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit git-r3 python-any-r1 scons-utils toolchain-funcs

DESCRIPTION="Multimedia library for C language beginners (graphics, sound, physics)"
HOMEPAGE="https://coolbug.org/users/bw/helianthus/"
EGIT_REPO_URI="https://coolbug.org/earthworm/repo/bw/helianthus"

LICENSE="public-domain"
SLOT="0"
KEYWORDS=""
IUSE=""

# Build-time dependencies
BDEPEND="dev-build/scons
    virtual/pkgconfig
    sys-devel/gcc"
# Build & run-time dependencies
DEPEND="media-libs/libsdl2
    media-libs/sdl2-mixer
    media-libs/sdl2-image
    media-libs/freetype:2"
RDEPEND="${DEPEND}"

src_prepare() {
  eapply "${FILESDIR}/helianthus-9999-prefix.patch"  # Apply our SConstruct prefix fix
  eapply_user  # Apply any user-supplied patches (EAPI ≥6)&#8203;:contentReference[oaicite:6]{index=6}
  # Adjust installation paths for Gentoo (use lib64 on 64-bit systems)
  sed -i -e "/idir_lib/s:\$PREFIX/lib:\$PREFIX/$(get_libdir):" src/SConstruct || die
  sed -i -e "s:'/usr/local':${EPREFIX}/usr:g" src/SConstruct || die
  default  # Apply any user patches if present
}

src_configure() {
    # Set up SCons build environment (compiler and prefix)
    MYSCONS=( CC="$(tc-getCC)" PREFIX="${EPREFIX}/usr" )
}

src_compile() {
    escons "${MYSCONS[@]}"
}

src_install() {
    # Use SCons to install into the image directory
    escons "${MYSCONS[@]}" DESTDIR="${D}" install || die "SCons install failed"
}
