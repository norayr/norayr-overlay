# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit mercurial meson xdg

DESCRIPTION="Multi-protocol instant messaging client, Pidgin 3 development branch"
HOMEPAGE="
	https://pidgin.im/
	https://keep.imfreedom.org/pidgin/pidgin
"

EHG_REPO_URI="https://keep.imfreedom.org/pidgin/pidgin"
EHG_REVISION="default"

LICENSE="GPL-2+"
SLOT="3"
KEYWORDS=""

IUSE="
	demo
	doc
	introspection
	+ircv3
	+libsecret
	+link-local-messaging
	sip
	xscreensaver
	+xmpp
	zulip
"

REQUIRED_USE="
	doc? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.82:2
	>=dev-libs/json-glib-1.4
	>=dev-libs/birb-0.7.1
	>=dev-libs/hasl-0.4.0
	>=dev-libs/seagull-0.8.1
	>=dev-libs/gplugin-0.44.2:0/0.44
	<dev-libs/gplugin-0.45

	>=media-libs/gstreamer-1.14:1.0
	>=media-libs/gst-plugins-base-1.14:1.0
	net-libs/libsoup:3.0
	>=x11-libs/pango-1.54

	>=gui-libs/gtk-4.20:4[introspection?]
	>=gui-libs/libadwaita-1.8:1[introspection?]
	>=gui-libs/gtksourceview-5.10:5[introspection?]
	>=app-text/libspelling-0.4

	introspection? ( dev-libs/gobject-introspection )
	libsecret? ( app-crypt/libsecret )
	xscreensaver? (
		x11-libs/libX11
		x11-libs/libXScrnSaver
	)
	link-local-messaging? ( net-dns/avahi[dbus] )
	xmpp? ( dev-libs/libxml2:2 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( >=dev-util/gi-docgen-2025.3 )
"

src_configure() {
	local emesonargs=(
		-Dgtkui=true
		-Dunity-integration=disabled

		$(meson_use doc doc)
		$(meson_use introspection introspection)

		$(meson_feature libsecret libsecret)
		$(meson_feature xscreensaver idle-xscreensaver)

		$(meson_feature demo demo)
		$(meson_feature ircv3 ircv3)
		$(meson_feature link-local-messaging link-local-messaging)
		$(meson_feature sip sip)
		$(meson_feature xmpp xmpp)
		$(meson_feature zulip zulip)
	)

	meson_src_configure
}
