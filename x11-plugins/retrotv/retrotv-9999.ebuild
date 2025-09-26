# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Window Maker dockapp that plays 64x64 MP4s with a CRT overlay"
HOMEPAGE="https://codeberg.org/Bainne/retrotv-dock"
EGIT_REPO_URI="https://codeberg.org/Bainne/retrotv-dock.git"

# Upstream doesn't clearly state a license in README;
# change this if you confirm a specific license later.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE=""

# pkg-config is used during compile to discover flags/libs
BDEPEND="virtual/pkgconfig"

# Build-time and run-time deps (ffmpeg provides libav* & swscale)
DEPEND="
    media-libs/libsdl2
    media-libs/sdl2-image
    media-video/ffmpeg
    x11-libs/libX11
    x11-libs/libXpm
"
RDEPEND="${DEPEND}"

src_compile() {
    local cc=$(tc-getCC)

    # Compose flags via pkg-config exactly like upstream build line
    local pkgs=( sdl2 SDL2_image libavcodec libavformat libswscale libavutil x11 )
    local pc_cflags pc_libs
    pc_cflags=$(pkg-config --cflags "${pkgs[@]}") || die
    pc_libs=$(pkg-config --libs   "${pkgs[@]}") || die

    ${cc} ${CFLAGS} ${pc_cflags} \
        -o retrotvdock retrotv-dock.c \
        ${LDFLAGS} ${pc_libs} \
        -lm -ldl -lpthread \
        || die "compile failed"
}

src_install() {
    dobin retrotvdock

    # Install the overlay PNG so users have a known path to pass
    insinto /usr/share/retrotv-dock
    doins retrotv-darkblue.png

    # Helpful docs and screenshot (harmless if missing)
    dodoc README.md HUMAN_RIGHTS.txt retrotv-dock-screenshot.jpg
}

pkg_postinst() {
    elog "Usage:"
    elog "  retrotvdock <mp4 or directory> /usr/share/retrotv-dock/retrotv-darkblue.png"
    elog "Tip: Downsize videos to 64x64 and strip audio for low CPU."
}
