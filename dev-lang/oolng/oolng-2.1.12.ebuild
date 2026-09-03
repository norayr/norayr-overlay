# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib toolchain-funcs

DESCRIPTION="Optimizing compiler for an extended Oberon-2 language"
HOMEPAGE="https://github.com/norayr/oolng"
SRC_URI="https://github.com/norayr/oolng/archive/refs/tags/oolng-${PV}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${PN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

IUSE="+gc"

RDEPEND="
	dev-lang/perl
	dev-libs/libxslt
	gc? ( dev-libs/boehm-gc )
"
DEPEND="${RDEPEND}"

src_compile() {
	emake -j1 \
		PREFIX="${EPREFIX}/usr" \
		bindir="${EPREFIX}/usr/bin" \
		libdir="${EPREFIX}/usr/$(get_libdir)" \
		oocdir="${EPREFIX}/usr/$(get_libdir)/oolng" \
		mandir="${EPREFIX}/usr/share/man/man1" \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		CPPFLAGS="${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		BOEHM_GC="$(usex gc 1 0)"
}

src_install() {
	emake -j1 \
		PREFIX="${EPREFIX}/usr" \
		bindir="${ED}/usr/bin" \
		libdir="${ED}/usr/$(get_libdir)" \
		oocdir="${ED}/usr/$(get_libdir)/oolng" \
		mandir="${ED}/usr/share/man/man1" \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		CPPFLAGS="${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		BOEHM_GC="$(usex gc 1 0)" \
		RUN_LDCONFIG=0 \
		SUDO_USER= \
		install

			dodoc INSTALL PROBLEMS README README.md README.MACOS README.WIN32 known_issues.md

}
