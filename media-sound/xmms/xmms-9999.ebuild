# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 meson xdg

DESCRIPTION="GTK4/GStreamer revival of the classic XMMS player"
HOMEPAGE="https://gitlab.com/cschalle/xmms-resuscitated"
EGIT_REPO_URI="https://gitlab.com/cschalle/xmms-resuscitated.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="
	>=gui-libs/gtk-4.6:4
	>=media-libs/gstreamer-1.16:1.0
	>=media-libs/gst-plugins-base-1.16:1.0
	>=media-libs/gst-plugins-good-1.16:1.0
	>=media-plugins/gst-plugins-mpg123-1.24.0
	>=net-libs/libsoup-3.0:3.0
	>=dev-libs/json-glib-1.6
	>=app-arch/libarchive-3.0
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

DOCS=( README.md )

src_configure() {
	local emesonargs=(
		--bindir="${EPREFIX}/usr/bin"
	)
	meson_src_configure
}


