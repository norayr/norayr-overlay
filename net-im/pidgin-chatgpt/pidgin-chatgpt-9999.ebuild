# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="ChatGPT plugin for Pidgin/libpurple"
HOMEPAGE="https://github.com/EionRobb/pidgin-chatgpt"
SRC_URI="https://github.com/EionRobb/pidgin-chatgpt/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~ppc"
IUSE=""

RDEPEND="
  net-im/pidgin
  dev-libs/glib:2
  dev-libs/json-glib
  sys-libs/zlib
"

DEPEND="${RDEPEND}
  virtual/pkgconfig
"

S="${WORKDIR}/${PN}-master"

src_prepare() {
  default

  # Strip Windows logic and force libchatgpt.so target
  sed -i \
    -e '/^WIN32/d' \
    -e 's|$(PLUGIN_TARGET)|libchatgpt.so|' \
    -e 's|$(CC)|$(CC) $(CFLAGS)|g' \
    -e 's| -o $@| $(LDFLAGS) -o $@|' \
    -e 's|`$(PKG_CONFIG)|$(shell $(PKG_CONFIG)|g' \
    -e 's|purple2compat/http.c purple2compat/purple-socket.c|purple2compat/http.c purple2compat/purple-socket.c|' \
    Makefile || die
}

src_compile() {
  tc-export CC PKG_CONFIG

  emake \
    CFLAGS="${CFLAGS} $(${PKG_CONFIG} --cflags purple glib-2.0 json-glib-1.0 zlib) -fPIC -Ipurple2compat" \
    LDFLAGS="${LDFLAGS} $(${PKG_CONFIG} --libs purple glib-2.0 json-glib-1.0 zlib)" \
    libchatgpt.so
}

src_install() {
  # Install the plugin shared object
  exeinto "$(${PKG_CONFIG} --variable=plugindir purple)"
  doexe libchatgpt.so

  # Install icons if present
  local sizes=(16 22 48)
  for size in "${sizes[@]}"; do
    if [[ -f "icons/${size}/chatgpt.png" ]]; then
      insinto "/usr/share/pixmaps/pidgin/protocols/${size}"
      doins "icons/${size}/chatgpt.png"
    fi
  done

  dodoc README.md
}

