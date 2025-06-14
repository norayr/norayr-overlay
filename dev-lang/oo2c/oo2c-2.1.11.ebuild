EAPI=8

DESCRIPTION="Optimizing Oberon-2 to ANSI-C Translator (OO2C)"
HOMEPAGE="https://ooc.sourceforge.net/"
SRC_URI="
    amd64?  ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_64-2.1.11.tar.bz2 -> oo2c-2.1.11-amd64.tar.bz2 )
    x86?    ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-x86.tar.bz2 )
    arm64?  ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_64-2.1.11.tar.bz2 -> oo2c-2.1.11-arm64.tar.bz2 )
    arm?    ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-arm.tar.bz2 )
    ppc?    ( https://downloads.sourceforge.net/project/ooc/ooc2/2.1.11/oo2c_32-2.1.11.tar.bz2 -> oo2c-2.1.11-ppc.tar.bz2 )
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
S="${WORKDIR}/oo2c_${ABI}-2.1.11"


src_unpack() {
	local abibits
	if use amd64 || use arm64 || use ppc64; then
		abibits="64"
	else
		abibits="32"
	fi

	ABI="${abibits}" # Make it available globally

	default  # Uses built-in unpack logic
	S="${WORKDIR}/oo2c_${abibits}-2.1.11"
}


src_configure() {
    local myconf=()

    use threads && myconf+=( --enable-threads=pthreads )

    econf "${myconf[@]}"

    # Patch CFLAGS in stage0/Makefile *after* it exists
    sed -i 's/^CFLAGS =/CFLAGS = -std=gnu99 /' stage0/Makefile || die "sed failed"
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


