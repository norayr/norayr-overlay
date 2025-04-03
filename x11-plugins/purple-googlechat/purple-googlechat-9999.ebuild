# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Google Chat plugin for libpurple"
HOMEPAGE="https://github.com/EionRobb/purple-googlechat"
SRC_URI="https://github.com/EionRobb/purple-googlechat/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~ppc"
IUSE=""

RDEPEND="
    net-im/pidgin
    dev-libs/glib:2
    dev-libs/json-glib
    net-libs/libpurple
    dev-libs/protobuf-c
"

DEPEND="${RDEPEND}
    dev-util/protobuf-c
    virtual/pkgconfig
"

S="${WORKDIR}/purple-googlechat-master"

src_compile() {
    emake
}

src_install() {
    # Install the plugin library
    insinto /usr/$(get_libdir)/purple-2
    doins libgooglechat.so

    # Optionally install icons or docs
    dodoc README.md
    insinto /usr/share/pixmaps/pidgin/protocols
    doins googlechat*.png
}

