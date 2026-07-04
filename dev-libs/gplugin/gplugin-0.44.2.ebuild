# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_USE_DEPEND="vapigen"
inherit meson vala

DESCRIPTION="GObject based reusable plugin system"
HOMEPAGE="
	https://docs.imfreedom.org/gplugin/
	https://keep.imfreedom.org/gplugin/gplugin/
"
SRC_URI="mirror://sourceforge/pidgin/${PN}/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0/0.44"
KEYWORDS="~amd64"

IUSE="
	doc
	+gtk
	introspection
	+nls
	vala
"

REQUIRED_USE="
	doc? ( introspection )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.76:2
	gtk? ( >=gui-libs/gtk-4.10:4[introspection?] )
	introspection? ( dev-libs/gobject-introspection )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	doc? ( >=dev-util/gi-docgen-2025.3 )
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	use vala && vala_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use doc doc)
		$(meson_use introspection introspection)
		$(meson_use nls nls)
		$(meson_use vala vapi)

		$(meson_feature gtk gtk4)
		-Dinstall-gplugin-gtk4-viewer=$(usex gtk true false)

		-Dgplugin-introspection=false
		-Dhelp2man=false
		-Dinstall-gplugin-query=true
		-Dlua=false
		-Dpython3=false
	)

	meson_src_configure
}
