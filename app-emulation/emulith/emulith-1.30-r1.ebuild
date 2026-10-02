# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="ETH Lilith Modula-2 computer emulator"
HOMEPAGE="http://pascal.hansotten.com/niklaus-wirth/lilith/emulith/"
SRC_URI="
	http://pascal.hansotten.com/uploads/lilith/Emulith_v13.tgz -> ${P}.tgz
	http://pascal.hansotten.com/uploads/lilith/docu/LilithHandbook_Aug82.pdf
	compiler? (
		http://pascal.hansotten.com/uploads/lilith/ETH_Disks.zip
		http://pascal.hansotten.com/uploads/lilith/medos.zip
		http://pascal.hansotten.com/uploads/lilith/medos_txt.zip
	)
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="+floppy tools compiler"

RDEPEND="
	x11-libs/fltk:1
	x11-libs/libX11
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
	default

	# Emulith has identifiers b0..b7 which collide with names exposed by
	# modern headers pulled in by FLTK.  Hide them while FLTK is parsed.
	# Keep this compatibility patch local to the UI source.
	sed -i '/#include "lilith.h"/a \
#ifdef b0\n#undef b0\n#endif\n\
#ifdef b1\n#undef b1\n#endif\n\
#ifdef b2\n#undef b2\n#endif\n\
#ifdef b3\n#undef b3\n#endif\n\
#ifdef b4\n#undef b4\n#endif\n\
#ifdef b5\n#undef b5\n#endif\n\
#ifdef b6\n#undef b6\n#endif\n\
#ifdef b7\n#undef b7\n#endif' \
		Src/fltk_cde.c || die "failed to patch FLTK name collisions"
}

src_compile() {
	local -a fltk_cxxflags fltk_ldflags
	local -a sources=(
		Src/main.c
		Src/cpu.c
		Src/proms.c
		Src/fltk_cde.c
		Src/img_cde.c
		Src/io_proc.c
		Src/io_MD120.c
		Src/io_ST419.c
		Src/io_floppy.c
	)

	read -r -a fltk_cxxflags <<< "$(fltk-config --cxxflags)" \
		|| die "fltk-config --cxxflags failed"
	read -r -a fltk_ldflags <<< "$(fltk-config --use-forms --use-images --ldflags)" \
		|| die "fltk-config --ldflags failed"

	# Do not use upstream's 'make lin' here.  That target hard-codes g++,
	# optimisation flags, bundled-FLTK paths, and linker flags, so it ignores
	# Gentoo's selected toolchain and user flags.
	"$(tc-getCXX)" \
		${CPPFLAGS} ${CXXFLAGS} \
		"${fltk_cxxflags[@]}" \
		-Iinclude -Isupport \
		-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE \
		-D_THREAD_SAFE -D_REENTRANT -Dfl_ask_H \
		"${sources[@]}" \
		-o emulith \
		${LDFLAGS} "${fltk_ldflags[@]}" -lpthread \
		|| die "failed to compile Emulith"

	if use tools; then
		"$(tc-getCC)" \
			${CPPFLAGS} ${CFLAGS} \
			-Iinclude -Isupport \
			support/lft_main.c \
			-o lft ${LDFLAGS} \
			|| die "failed to compile lft"
	fi
}

src_install() {
	# Emulith is designed around a working directory containing its runtime
	# tree.  Keep one pristine, package-owned template under /opt and never
	# run the emulator against those master disk images directly.
	exeinto /opt/${PN}
	doexe emulith

	insinto /opt/${PN}/runtime
	doins ascii.def emulith.ini
	doins -r img mcode

	if use floppy; then
		doins -r floppy
	fi

	# These are archival/reference media.  Keep the distributed archives
	# pristine; users can extract/copy whichever images they want into their
	# writable Emulith working tree.
	if use compiler; then
		insinto /opt/${PN}/media
		doins \
			"${DISTDIR}/ETH_Disks.zip" \
			"${DISTDIR}/medos.zip" \
			"${DISTDIR}/medos_txt.zip"
	fi

	if use tools; then
		newbin lft emulith-lft
	fi

	# Initialise a private writable working tree.  EMULITH_HOME can be used
	# to keep several independent Lilith installations/disk sets.
	cat > "${T}/emulith-setup" <<'EOF_SETUP'
#!/bin/sh
set -eu

src=/opt/emulith/runtime
home=${EMULITH_HOME:-${XDG_DATA_HOME:-"${HOME}/.local/share"}/emulith}

if [ -e "${home}" ]; then
	echo "emulith-setup: ${home} already exists; refusing to overwrite it" >&2
	exit 1
fi

mkdir -p "${home}"
cp -a "${src}/." "${home}/"
chmod -R u+rwX "${home}"
mkdir -p "${home}/vid"

printf '%s\n' \
	"Created writable Emulith working tree:" \
	"  ${home}" \
	"" \
	"The disk images in this directory belong to you and may be modified" \
	"by the emulated Lilith.  Portage will not overwrite them."
EOF_SETUP
	dobin "${T}/emulith-setup"

	cat > "${T}/emulith" <<'EOF_RUN'
#!/bin/sh
set -eu

home=${EMULITH_HOME:-${XDG_DATA_HOME:-"${HOME}/.local/share"}/emulith}

if [ ! -f "${home}/emulith.ini" ] || [ ! -d "${home}/img" ] || [ ! -d "${home}/mcode" ]; then
	echo "Emulith has no writable working tree at:" >&2
	echo "  ${home}" >&2
	echo >&2
	echo "Run 'emulith-setup' once, or set EMULITH_HOME to an existing Emulith tree." >&2
	exit 1
fi

cd "${home}"
exec /opt/emulith/emulith "$@"
EOF_RUN
	dobin "${T}/emulith"

	# Upstream documentation.
	dodoc "${DISTDIR}/LilithHandbook_Aug82.pdf"
	dodoc docu/Emulith_Manual_1.3.pdf docu/18-03-2012.txt
}

pkg_postinst() {
	elog "Emulith is a working-directory-oriented emulator."
	elog "The package-owned pristine runtime is installed in:"
	elog "  /opt/emulith/runtime"
	elog
	elog "Before the first run, create your writable private copy with:"
	elog "  emulith-setup"
	elog
	elog "Then start it with:"
	elog "  emulith"
	elog
	elog "By default the writable tree is:"
	elog '  ${XDG_DATA_HOME:-$HOME/.local/share}/emulith'
	elog "Set EMULITH_HOME if you want a different tree or several independent"
	elog "Lilith disk sets.  The launcher always changes into that directory"
	elog "before starting the emulator."

	if use compiler; then
		elog
		elog "Additional historical Lilith/Medos media archives are installed in:"
		elog "  /opt/emulith/media"
		elog "Extract/copy the media you want into a writable working tree; do not"
		elog "use the package-owned copies as live disks."
	fi
}
