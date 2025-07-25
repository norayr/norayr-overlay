# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="ChatGPT plugin for Pidgin/libpurple"
HOMEPAGE="https://github.com/EionRobb/pidgin-chatgpt"
EGIT_REPO_URI="https://github.com/EionRobb/pidgin-chatgpt.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
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

src_prepare() {
  default
}

src_compile() {
  tc-export CC PKG_CONFIG

  local cflags="${CFLAGS} -fPIC -Ipurple2compat $(${PKG_CONFIG} --cflags purple glib-2.0 json-glib-1.0 zlib)"
  local ldflags="${LDFLAGS} $(${PKG_CONFIG} --libs purple glib-2.0 json-glib-1.0 zlib)"
  local sources="libchatgpt.c markdown.c purple2compat/http.c purple2compat/purple-socket.c"

  ${CC} ${cflags} -shared -o libchatgpt.so ${sources} ${ldflags} || die "compilation failed"
}

src_install() {
  exeinto "$(${PKG_CONFIG} --variable=plugindir purple)"
  doexe libchatgpt.so

  local sizes=(16 22 48)
  for size in "${sizes[@]}"; do
    if [[ -f "icons/${size}/chatgpt.png" ]]; then
      insinto "/usr/share/pixmaps/pidgin/protocols/${size}"
      doins "icons/${size}/chatgpt.png"
    fi
  done

  dodoc README.md
}
