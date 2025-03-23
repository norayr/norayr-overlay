EAPI=8

inherit qmake-utils git-r3

DESCRIPTION="An emulator for Intel 8080 CPU"
HOMEPAGE="https://github.com/vpyk/emu80v4"
EGIT_REPO_URI="https://github.com/vpyk/emu80v4.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE="qt sdl lite"
REQUIRED_USE="^^ ( qt sdl lite )"

DEPEND="
	qt? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	sdl? (
		media-libs/libsdl2
		x11-libs/wxGTK:3.0
	)
	lite? (
		media-libs/libsdl2
	)
"

RDEPEND="${DEPEND}"

src_configure() {
	if use qt; then
		cd src || die
		eqmake5 Emu80qt.pro
	fi
}

src_compile() {
	if use qt; then
		cd src || die
		emake
	elif use sdl; then
		emake -f Makefile.sdlwx
	elif use lite; then
		emake -f Makefile.lite
	fi
}

src_install() {
    if use qt; then
        cd src || die
        dobin Emu80qt
    elif use sdl; then
        emake -f Makefile.sdlwx
        dobin Emu80sdlwx
        insinto /usr/share/emu80
        doins -r dist/*
    elif use lite; then
        emake -f Makefile.lite
        dobin Emu80lite
        insinto /usr/share/emu80
        doins -r dist/*
        newdoc COPYING.txt COPYING
        dodoc whatsnew.txt doc/*
        echo "emulation.runPlatform = apogey" > emu80.run
        insinto /usr/share/emu80
        doins emu80.run
    fi
}
