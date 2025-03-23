EAPI=8

DESCRIPTION="Dockapp for laptop power status and control (APM/ACPI/CPUFreq)"
HOMEPAGE="https://sourceforge.net/projects/wmlaptop/"
SRC_URI="mirror://sourceforge/wmlaptop/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="longrun acpi"

DEPEND="x11-libs/libX11
  x11-libs/libXext"
RDEPEND="${DEPEND}
  acpi? ( sys-power/acpi )
  virtual/logger"

src_prepare() {
  default
  # Optionally patch or sed Makefile to change install path
  sed -i \
    -e "s|^INSTALLDIR *=.*|INSTALLDIR = /usr/bin|" \
    Makefile || die
}

src_compile() {
  if use longrun; then
    emake -f Makefile.Longrun
  else
    emake
  fi
}

src_install() {
  dobin src/wmlaptop
  doman man/wmlaptop.1
  dodoc README INSTALL CHANGELOG
}

pkg_postinst() {
  elog "To allow wmlaptop to shutdown the system as a regular user,"
  elog "you may need to configure sudo. Add the following to /etc/sudoers:"
  elog ""
  elog "  youruser ALL=(root) NOPASSWD: /sbin/shutdown"
  elog ""
  elog "You may also want to adjust SHUTDOWN_BIN or SHUTDOWN_ARGS in src/autoscript.h"
}
