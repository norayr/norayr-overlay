# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="HyperCard-inspired multimedia sketchpad with Lil scripting"
HOMEPAGE="https://github.com/JohnEarnest/Decker"
EGIT_REPO_URI="https://github.com/JohnEarnest/Decker.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="danger"

DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	app-editors/vim-core
	dev-build/make
	x11-misc/shared-mime-info
"

src_compile() {
	local myflags="${CFLAGS}"

	if use danger; then
		myflags+=" -DDANGER_ZONE"
	fi

	emake \
		EXTRA_FLAGS="${myflags}" \
		lilt decker
}

src_test() {
	local myflags="${CFLAGS}"

	if use danger; then
		myflags+=" -DDANGER_ZONE"
	fi

	emake \
		EXTRA_FLAGS="${myflags}" \
		test
}

src_install() {
	dobin c/build/decker
	newbin c/build/lilt lilt

	insinto /usr/share/${PN}
	doins -r examples

	dodoc Readme.md LICENSE.txt
	docinto docs
	dodoc docs/*.md

	domenu Decker.desktop

	for size in 32 64 128 192 256 512; do
		newicon -s ${size} icon_${size}x${size}.png decker.png
		insinto /usr/share/icons/hicolor/${size}x${size}/mimetypes
		newins icon_${size}x${size}.png x-decker.png
	done

	insinto /usr/share/mime/packages
	doins x-decker.xml

	insinto /usr/share/vim/vimfiles
	doins -r syntax/vim/*
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}

