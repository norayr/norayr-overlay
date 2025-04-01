EAPI=8

DESCRIPTION="VueScan scanner software by Hamrick (GTK2, 64-bit only)"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="https://www.hamrick.com/oldfiles/vuex6496.tgz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

RDEPEND="
    x11-libs/gtk+:2
    x11-libs/gdk-pixbuf:2
    x11-libs/pango
    x11-libs/cairo
    dev-libs/glib:2
    dev-libs/atk
    virtual/libusb:1
    x11-libs/libX11
    x11-libs/libSM
    virtual/libudev
    sys-libs/zlib
"

S="${WORKDIR}/VueScan"

src_install() {
    dobin vuescan

    # Optional: install VueScan plugins (Photoshop TWAIN/Acquire? Not typically needed)
    insinto /usr/share/vuescan
    doins vuescan.8ba vuescan.ds

    # Install icon
    insinto /usr/share/icons/hicolor/scalable/apps
    doins vuescan.svg

    # Optional: install desktop file
    make_desktop_entry vuescan "VueScan" vuescan Scanner
}

pkg_postinst() {
    xdg_icon_cache_update
}

pkg_postrm() {
    xdg_icon_cache_update
}
