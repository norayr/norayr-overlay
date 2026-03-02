# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Barev - XMPP flavoured serverless protocol plugin for Pidgin/libpurple"
HOMEPAGE="https://codeberg.org/norayr/barev-purple"
EGIT_REPO_URI="https://codeberg.org/norayr/barev-purple.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~x86_64 ~arm ~arm64 ~ppc ~ppc64 ~riscv"

# Needs pkg-config for plugindir/datadir lookups and for cflags/libs
BDEPEND="virtual/pkgconfig"

# Build-time headers/libs (Makefile uses pkg-config for these)
DEPEND="
  net-im/pidgin
  dev-libs/glib:2
  dev-libs/libxml2
"

# plugin needs yggdrasil running
RDEPEND="
  ${DEPEND}
  net-p2p/yggdrasil-go
"

src_compile() {
  emake \
    CC="$(tc-getCC)"
}

src_install() {
  emake DESTDIR="${D}" install

  if [[ -e "${ED}"/usr/$(get_libdir)/purple-2/libbarev.so ]]; then
    fperms 0755 /usr/$(get_libdir)/purple-2/libbarev.so
  fi
}

pkg_postinst() {
  elog "barev purple plugin installed."
  elog
  elog "To use it:"
  elog "  1) Configure and start Yggdrasil (net-p2p/yggdrasil-go) and ensure you have peers."
  elog "  2) Open Pidgin -> Accounts -> Manage Accounts -> Add."
  elog "  3) Choose protocol 'barev' and pick a nickname."
  elog
  elog "If the protocol does not appear, restart Pidgin."
}


