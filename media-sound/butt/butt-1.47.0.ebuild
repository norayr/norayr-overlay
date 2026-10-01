# Copyright 2025-2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Broadcast Using This Tool - audio streaming client for Icecast and SHOUTcast"
HOMEPAGE="https://danielnoethen.de/butt/"
SRC_URI="https://danielnoethen.de/butt/release/${PV}/butt-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="aac"

RDEPEND="
  >=x11-libs/fltk-1.4.5:1=
  media-libs/portaudio
  media-libs/portmidi
  media-sound/lame
  media-libs/libogg
  media-libs/libvorbis
  media-libs/opus
  media-libs/flac
  media-libs/libsamplerate
  net-misc/curl
  dev-libs/openssl:=
  sys-apps/dbus
  aac? ( media-libs/fdk-aac )
"
DEPEND="${RDEPEND}"
BDEPEND="
  sys-devel/gettext
  virtual/pkgconfig
"

S="${WORKDIR}/butt-${PV}"

src_configure() {
  econf \
    $(use_enable aac)
}

src_install() {
  default
  dobin src/butt
  doman butt.1
}
