EAPI=8

inherit cmake git-r3

DESCRIPTION="Oricutron is an Oric emulator"
HOMEPAGE="https://github.com/pete-gordon/oricutron"
EGIT_REPO_URI="https://github.com/pete-gordon/oricutron.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="sdl2"

RDEPEND="
  sdl2? (
    media-libs/libsdl2
  )
  !sdl2? (
    media-libs/libsdl
  )
  x11-libs/gtk+:3
  media-libs/libglvnd
  x11-libs/libX11
"
DEPEND="${RDEPEND}"

BDEPEND="
  virtual/pkgconfig
  dev-build/ninja
"

src_configure() {
  local mycmakeargs=(
    -G Ninja
    $(usex sdl2 -DUSE_SDL2=ON -DUSE_SDL2=OFF)
  )
  cmake_src_configure
}

src_install() {
if use sdl2; then
    dobin "${BUILD_DIR}/Oricutron-sdl2"
else
    dobin "${BUILD_DIR}/Oricutron"
fi

  dodoc ReadMe.txt ChangeLog.txt oricutron.cfg

  insinto /usr/share/oricutron/images
  doins images/* || die

  insinto /usr/share/oricutron/roms
  doins roms/* || die

  insinto /usr/share/oricutron/tapes
  doins -r tapes || die

  insinto /usr/share/oricutron/disks
  doins -r disks || die

  insinto /usr/share/oricutron/pravdisks
  doins -r pravdisks || die

  insinto /usr/share/oricutron/teledisks
  doins -r teledisks || die
}
