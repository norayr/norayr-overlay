EAPI=8

DESCRIPTION="VueScan scanner software by Hamrick (GTK2, 32-bit only)"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="
    x86? ( https://files.hamrick.com/version-archive/9.8.37/vuex3298.tgz )
    arm? ( https://files.hamrick.com/version-archive/9.8.37/vuea3298.tgz )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE=""

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
