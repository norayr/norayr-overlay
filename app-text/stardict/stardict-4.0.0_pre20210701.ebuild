# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic gnome2

DESCRIPTION="An international dictionary supporting fuzzy and glob-style matching"
HOMEPAGE="https://github.com/huzheng001/stardict-3"
SRC_URI="
  https://github.com/huzheng001/stardict-3/archive/96b96d89eab5f0ad9246c2569a807d6d7982aa84.tar.gz -> ${P}.tar.gz
    pronounce? ( mirror://sourceforge/stardict-4/WyabdcRealPeopleTTS/WyabdcRealPeopleTTS.tar.bz2 )
"

S="${WORKDIR}/stardict-3-96b96d89eab5f0ad9246c2569a807d6d7982aa84"


LICENSE="CPL-1.0 GPL-3 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc ~ppc64 ~riscv"
IUSE="advertisement cal canberra debug dictdotcn espeak examples flite fortune gnome gucharmap htmlparse info man perl powerwordparse pronounce spell tools updateinfo wikiparse wordnet xdxfparse youdaodict"

RESTRICT="test"

COMMON_DEPEND="
  >=dev-libs/glib-2.32:2
  dev-libs/libsigc++:2
  x11-libs/gtk+:3
  x11-libs/libX11
  x11-libs/gdk-pixbuf:2
  x11-libs/pango
  sys-libs/zlib
  canberra? ( media-libs/libcanberra[gtk3] )
  espeak? ( >=app-accessibility/espeak-1.29 )
  flite? ( app-accessibility/flite )
  gucharmap? ( gnome-extra/gucharmap:2.90= )
  spell? ( >=app-text/enchant-1.2:0= )
  tools? (
    dev-db/mysql-connector-c
    dev-libs/expat
    dev-libs/libpcre
    dev-libs/libxml2
  )
"
RDEPEND="${COMMON_DEPEND}
  info? ( sys-apps/texinfo )
  fortune? ( games-misc/fortune-mod )
  perl? ( dev-lang/perl )
"
DEPEND="${COMMON_DEPEND}
  gnome? (
    app-text/docbook-xml-dtd:4.3
    app-text/gnome-doc-utils
    dev-libs/libxslt
  )
  dev-util/intltool
  sys-devel/gettext
  virtual/pkgconfig
"

src_prepare() {
  default

  # Compatibility with newer GCC
  append-cxxflags -Wno-deprecated-declarations -fpermissive

  sed -i '/AM_GCONF_SOURCE_2/d' dict/configure.ac || die

  if ! use gnome; then
    sed -i \
      -e '/GNOME_DOC_INIT/d' \
      -e '/help\/Makefile/d' dict/configure.ac || die
    sed -i '/help/d' dict/Makefile.am || die
  fi

  if ! use canberra; then
    sed -i 's/ libcanberra libcanberra-gtk3//' dict/configure.ac || die
  fi

  eautoreconf
}

src_configure() {
  gnome2_src_configure \
    --disable-darwin-support \
    --disable-festival \
    --disable-gnome-support \
    --disable-gpe-support \
    --disable-maemo-support \
    --disable-schemas-install \
    --disable-scrollkeeper \
    $(use_enable advertisement) \
    $(use_enable cal) \
    $(use_enable debug) \
    $(use_enable dictdotcn) \
    $(use_enable espeak) \
    $(use_enable flite) \
    $(use_enable fortune) \
    $(use_enable gucharmap) \
    $(use_enable htmlparse) \
    $(use_enable info) \
    $(use_enable man) \
    $(use_enable powerwordparse) \
    $(use_enable spell) \
    $(use_enable tools) \
    $(use_enable updateinfo) \
    $(use_enable wikiparse) \
    $(use_enable wordnet) \
    $(use_enable xdxfparse) \
    $(use_enable youdaodict)
}

src_install() {
  gnome2_src_install
  dodoc AUTHORS ChangeLog README

  if use pronounce; then
    insinto /usr/share
    doins -r "${WORKDIR}/WyabdcRealPeopleTTS"
  fi

  if use examples; then
    docinto examples
    dodoc dict/doc/stardict-textual-dict*
  fi
}

pkg_postinst() {
  gnome2_pkg_postinst

  elog
  elog "You will need to install Stardict dictionary files to use the program."
  elog "You may find them via:"
  elog "  emerge -s stardict-"
  elog "Or manually extract them to:"
  elog "  /usr/share/stardict/dic"
  elog
}

