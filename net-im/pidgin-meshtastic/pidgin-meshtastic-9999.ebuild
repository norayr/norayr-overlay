# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Pidgin plugin for Meshtastic radio messaging"
HOMEPAGE="https://github.com/dadecoza/pidgin-meshtastic"
EGIT_REPO_URI="https://github.com/dadecoza/pidgin-meshtastic.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/glib:2
	net-im/pidgin
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default
	# ensure nanopb is initialized
	if [[ ! -d nanopb ]]; then
		einfo "Cloning nanopb submodule"
		git submodule update --init --recursive || die
	fi
}

src_compile() {
	tc-export CC PKG_CONFIG

	# Build pkg-config flags
	local mycflags="$(${PKG_CONFIG} --cflags glib-2.0 purple)"
	local myldflags="$(${PKG_CONFIG} --libs glib-2.0 purple)"

	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} ${mycflags} -Wall -Werror -fPIC" \
		LDFLAGS="${LDFLAGS} ${myldflags}" \
		CSRC="$(sed -n 's/^CSRC = \(.*\)/\1/p' Makefile)"
}

src_install() {
	# Install the plugin .so file
	insinto "$(pkg-config --variable=plugindir purple)"
	doins libmeshtastic.so

	# Install icons
	local sizes=(16 22 48)
	for size in "${sizes[@]}"; do
		insinto "/usr/share/pixmaps/pidgin/protocols/${size}"
		doins "pixmaps/pidgin/protocols/${size}/meshtastic.png"
	done

	for i in {0..4}; do
		insinto "/usr/share/pixmaps/pidgin/emblems/16"
		doins "pixmaps/pidgin/emblems/16/meshtastic-signal-${i}.png"
	done
}

pkg_postinst() {
	elog "Make sure your user is in the 'dialout' group if you're using serial Meshtastic devices:"
	elog "  sudo usermod -aG dialout \${USER}"
	elog
	elog "Restart Pidgin after installing the plugin."
}
