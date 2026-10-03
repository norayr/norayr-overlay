EAPI=8

DESCRIPTION="Firmware ROM images for Oric, Atmos, Pravetz and Telestrat emulation"
HOMEPAGE="https://norayr.am/collections/roms/oric/"
SRC_URI="https://norayr.am/collections/roms/oric/${P}.tar.bz2"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

S="${WORKDIR}/${P}"

src_install() {
	insinto /usr/share/oricutron/roms
	doins *.rom
}
