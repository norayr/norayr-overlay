EAPI=8

inherit cmake git-r3

DESCRIPTION="Portable Oric-1/Atmos/Telestrat and Pravetz 8D emulator"
HOMEPAGE="https://github.com/pete-gordon/oricutron"
EGIT_REPO_URI="https://github.com/pete-gordon/oricutron.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="sdl2"

RDEPEND="
	app-emulation/oric-roms
	sdl2? (
		media-libs/libsdl2
	)
	!sdl2? (
		media-libs/libsdl
		x11-libs/gtk+:3
	)
	media-libs/libglvnd
	x11-libs/libX11
"
DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
	dev-build/ninja
"

src_prepare() {
	cmake_src_prepare

	# On Linux upstream derives the data directory from realpath(argv[0]).
	# This has two problems for a normal Unix installation:
	#   1. invoking "Oricutron" through PATH can make realpath(argv[0]) fail;
	#   2. resources are installed in /usr/share/oricutron, not next to /usr/bin.
	# Keep the upstream behaviour for macOS, but use the packaged data directory
	# directly on Linux.
	sed -i \
		"s@#elif defined(__linux__) || defined(__APPLE__)@#elif defined(__linux__)\\n\\n  fileprefix = \"${EPREFIX}/usr/share/oricutron/\";\\n\\n#elif defined(__APPLE__)@" \
		main.c || die "failed to patch Oricutron resource path"

	grep -Fq "fileprefix = \"${EPREFIX}/usr/share/oricutron/\";" main.c ||
		die "Oricutron resource-path patch did not apply"
}

src_configure() {
	local mycmakeargs=(
		-G Ninja
		$(usex sdl2 -DUSE_SDL2=ON -DUSE_SDL2=OFF)
	)

	cmake_src_configure
}

src_install() {
	if use sdl2; then
		newbin "${BUILD_DIR}/Oricutron-sdl2" Oricutron
	else
		dobin "${BUILD_DIR}/Oricutron"
	fi

	dodoc ReadMe.txt ChangeLog.txt

	# Oricutron prefixes relative paths from oricutron.cfg with this directory,
	# so keep the config file and its resource directories together.
	insinto /usr/share/oricutron
	doins oricutron.cfg
	doins -r images roms tapes disks pravdisks teledisks
}
