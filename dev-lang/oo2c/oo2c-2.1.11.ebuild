EAPI=8

DESCRIPTION="Optimizing Oberon-2 to ANSI-C Translator (OO2C)"
HOMEPAGE="https://ooc.sourceforge.net/"
SRC_URI="
    amd64? ( oo2c-2.1.11-64bit.tar.bz2 )
    x86? ( oo2c-2.1.11-32bit.tar.bz2 )
    arm64? ( oo2c-2.1.11-64bit.tar.bz2 )
    arm? ( oo2c-2.1.11-32bit.tar.bz2 )
    ppc? ( oo2c-2.1.11-32bit.tar.bz2 )
    https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_64-2.1.11.tar.bz2 -> oo2c-2.1.11-64bit.tar.bz2
    https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-32bit.tar.bz2
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE="threads doc"

DEPEND="
  dev-lang/perl
  app-arch/tar
  sys-devel/gcc
  dev-libs/libxslt
  threads? ( dev-libs/boehm-gc )
"
RDEPEND="${DEPEND}"

# Select correct unpacked directory
S="${WORKDIR}/oo2c_${ABI_BITS}-2.1.11"

src_unpack() {
  local archive

  if use amd64 || use arm64 || use ppc64; then
    archive="${DISTDIR}/oo2c-2.1.11-64bit.tar.bz2"
    export ABI_BITS="64"
  else
    archive="${DISTDIR}/oo2c-2.1.11-32bit.tar.bz2"
    export ABI_BITS="32"
  fi

  mkdir -p "${WORKDIR}" || die
  tar -xjf "${archive}" -C "${WORKDIR}" || die "Failed to unpack oo2c tarball"
}

src_configure() {
  local myconf=()

  use threads && myconf+=( --enable-threads=pthreads )

  econf "${myconf[@]}"
}

src_compile() {
  emake
}

src_install() {
  default
  dodoc README* INSTALL PROBLEMS

  if use doc; then
    docinto html
    dodoc -r lib/oocdoc/html
  fi
}

pkg_postinst() {
  elog "To enable garbage collection, install dev-libs/boehm-gc and re-emerge with USE=threads"
}


