# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit mercurial meson

DESCRIPTION="IRCv3 parsing and integration library used by Pidgin"
HOMEPAGE="
	https://docs.imfreedom.org/ibis/
	https://keep.imfreedom.org/ibis/ibis/
"

EHG_REPO_URI="https://keep.imfreedom.org/ibis/ibis"
EHG_REVISION="default"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS=""

IUSE="doc introspection"

REQUIRED_USE="
	doc? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.80:2
	>=dev-libs/birb-0.3.1
	>=dev-libs/hasl-0.4.0
	>=x11-libs/pango-1.54
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
