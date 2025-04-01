EAPI=8

DESCRIPTION="VueScan scanner software by Hamrick (older GTK2 version)"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="
    amd64? ( https://files.hamrick.com/version-archive/9.8.37/vuex3298.tgz )
    arm64? ( https://files.hamrick.com/version-archive/9.8.37/vuea3298.tgz )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

RDEPEND="
    x11-libs/gtk+:2
    x11-libs/libX11
    dev-libs/glib:2
    x11-libs/pango
    media-libs/freetype
    media-libs/fontconfig
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
