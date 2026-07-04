# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit mercurial meson

DESCRIPTION="High-level XMPP parsing library used by Pidgin and IMFreedom projects"
HOMEPAGE="
	https://docs.imfreedom.org/xeme/
	https://keep.imfreedom.org/xeme/xeme/
"

EHG_REPO_URI="https://keep.imfreedom.org/xeme/xeme"
EHG_REVISION="default"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS=""

IUSE="doc introspection"

REQUIRED_USE="
	doc? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.76:2
	introspection? ( dev-libs/gobject-introspection )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( >=dev-util/gi-docgen-2025.3 )
"

src_configure() {
	local emesonargs=(
		$(meson_use doc doc)
		$(meson_use introspection introspection)
	)

	meson_src_configure
}
