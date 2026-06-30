# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Show images in a terminal using 24-bit ANSI colours"
HOMEPAGE="https://github.com/stolk/imcat"
EGIT_REPO_URI="https://github.com/stolk/imcat.git"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS=""

src_compile() {
	"$(tc-getCC)" \
		${CPPFLAGS} ${CFLAGS} \
		-D_POSIX_C_SOURCE=2 \
		-std=c99 \
		-Wall \
		-o imcat \
		imcat.c \
		${LDFLAGS} \
		-lm ||
		die "compiling imcat failed"
}

src_install() {
	dobin imcat
	doman imcat.1
	dodoc README.md
}
