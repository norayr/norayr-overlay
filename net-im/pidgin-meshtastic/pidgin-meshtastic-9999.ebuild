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

  sed -i \
    -e '/^CFLAGS *=/d' \
    -e '/^LDFLAGS *=/d' \
    -e 's/^libmeshtastic.so:.*/libmeshtastic.so: $(CSRC)/' \
    -e 's|$(CC).*|$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)|' \
    Makefile || die
}

src_compile() {
	tc-export CC PKG_CONFIG

	local mycflags="$(${PKG_CONFIG} --cflags glib-2.0 purple)"
	local myldflags="$(${PKG_CONFIG} --libs glib-2.0 purple)"

	local csrc="meshtastic/mesh.pb.c meshtastic/telemetry.pb.c meshtastic/config.pb.c meshtastic/channel.pb.c meshtastic/xmodem.pb.c meshtastic/device_ui.pb.c meshtastic/module_config.pb.c meshtastic/admin.pb.c meshtastic/connection_status.pb.c nanopb/pb_encode.c nanopb/pb_decode.c nanopb/pb_common.c mtstrings.c meshtastic.c"

	emake \
		CFLAGS="${CFLAGS} ${mycflags} -Wall -Werror -fPIC -I. -Inanopb" \
		LDFLAGS="${LDFLAGS} ${myldflags}" \
		CSRC="${csrc}"
}

src_install() {
  # Install the plugin .so file
  #insinto "$(pkg-config --variable=plugindir purple)"
  #doins libmeshtastic.so
        #insinto "$(pkg-config --variable=plugindir purple)"
        #newins -m 0755 libmeshtastic.so libmeshtastic.so
        exeinto "$(pkg-config --variable=plugindir purple)"
        doexe libmeshtastic.so
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
