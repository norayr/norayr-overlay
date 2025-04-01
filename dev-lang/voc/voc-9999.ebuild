# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Vishap Oberon Compiler"
HOMEPAGE="https://github.com/vishapoberon/compiler"
EGIT_REPO_URI="https://github.com/vishapoberon/compiler.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+gcc clang tcc"

REQUIRED_USE="^^ ( gcc clang tcc )"

DEPEND="sys-devel/make
	gcc?   ( sys-devel/gcc )
	clang? ( sys-devel/clang )
	tcc?   ( dev-lang/tcc )"

RDEPEND="${DEPEND}"

inherit git-r3

src_compile() {
	# Choose the compiler
	if use gcc; then
		export CC=gcc
		export VOC_INSTALLDIR="/opt/voc-gcc"
	elif use clang; then
		export CC=clang
		export VOC_INSTALLDIR="/opt/voc-clang"
	elif use tcc; then
		export CC=tcc
		export VOC_INSTALLDIR="/opt/voc-tcc"
	fi

	emake full
}

src_install() {
	# Use the same logic to install to the matching subdirectory
	if use gcc; then
		local instdir="/opt/voc-gcc"
	elif use clang; then
		local instdir="/opt/voc-clang"
	elif use tcc; then
		local instdir="/opt/voc-tcc"
	fi

	dodir "${instdir}"
	emake DESTDIR="${D}${instdir}" install

	# Symlinks
	dosym "${instdir}/bin/voc" /usr/bin/voc
	dosym "${instdir}/bin/showdef" /usr/bin/showdef
}
