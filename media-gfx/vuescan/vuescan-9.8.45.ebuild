EAPI=8

DESCRIPTION="VueScan scanner software by Hamrick (GTK3, Wayland-only)"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="
    amd64? ( https://www.hamrick.com/files/vuex6498.tgz )
    arm64? ( https://www.hamrick.com/files/vuea6498.tgz )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

RDEPEND="
    x11-libs/gtk+:3[wayland]
    x11-libs/gdk-pixbuf
    x11-libs/libX11
    dev-libs/glib:2
    x11-libs/pango
    media-libs/freetype
    media-libs/fontconfig
    sys-libs/zlib
    virtual/libudev
"

S="${WORKDIR}/VueScan"

src_install() {
    dobin vuescan

    insinto /lib/udev/rules.d
    newins vuescan.rul 60-vuescan.rules

    insinto /usr/share/icons/hicolor/scalable/apps
    doins vuescan.svg

    dodoc README.txt
}

pkg_postinst() {
    udevadm control --reload-rules
    xdg_icon_cache_update
}

pkg_postrm() {
    xdg_icon_cache_update
}
