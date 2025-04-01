EAPI=8

DESCRIPTION="VueScan scanner software by Hamrick"
HOMEPAGE="https://www.hamrick.com/"
SRC_URI="
    amd64? ( https://www.hamrick.com/files/vuex6498.tgz )
    arm64? ( https://www.hamrick.com/files/vuea6498.tgz )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

S="${WORKDIR}/VueScan"

src_install() {
    # Main binary
    dobin vuescan

    # Udev rules
    insinto /lib/udev/rules.d
    newins vuescan.rul 60-vuescan.rules

    # App icon
    insinto /usr/share/icons/hicolor/scalable/apps
    doins vuescan.svg

    # Documentation
    dodoc README.txt
}
