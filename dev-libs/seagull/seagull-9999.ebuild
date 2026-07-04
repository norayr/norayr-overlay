# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_USE_DEPEND="vapigen"
inherit mercurial meson vala

DESCRIPTION="SQLite3 utility library used by Pidgin and IMFreedom projects"
HOMEPAGE="
	https://docs.imfreedom.org/seagull/
	https://keep.imfreedom.org/seagull/seagull/
"

EHG_REPO_URI="https://keep.imfreedom.org/seagull/seagull"
EHG_REVISION="default"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS=""

IUSE="doc introspection vala"

REQUIRED_USE="
	doc? ( introspection )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.76:2
	dev-db/sqlite:3
	introspection? ( dev-libs/gobject-introspection )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( >=dev-util/gi-docgen-2025.3 )
	vala? ( $(vala_depend) )
"

src_configure() {
	local emesonargs=(
		$(meson_use doc doc)
		$(meson_use introspection introspection)
		$(meson_use vala vapi)
	)

	meson_src_configure
}
