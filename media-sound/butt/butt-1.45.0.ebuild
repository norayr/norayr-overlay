# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Broadcast Using This Tool - audio streaming client for Icecast and SHOUTcast"
HOMEPAGE="https://danielnoethen.de/butt/"
SRC_URI="https://danielnoethen.de/butt/release/${PV}/butt-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE="aac alsa flac jack opus vorbis"

DEPEND="
  x11-libs/fltk:1[static-libs]
  media-libs/portaudio
  media-libs/portmidi
  media-sound/lame
  media-libs/libogg
  media-libs/libsamplerate
  net-misc/curl
  dev-libs/openssl:=
  sys-apps/dbus
  alsa? ( media-libs/alsa-lib )
  flac? ( media-libs/flac )
  jack? ( virtual/jack )
  opus? ( media-libs/opus )
  vorbis? ( media-libs/libvorbis )
  aac? ( media-libs/fdk-aac )
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/butt-${PV}"

src_prepare() {
  default
  eautoreconf
}

src_configure() {
  econf \
    $(use_enable alsa) \
    $(use_enable flac) \
    $(use_enable jack) \
    $(use_enable opus) \
    $(use_enable vorbis) \
    $(use_enable aac)
}

src_install() {
  default
  dobin src/butt
  doman butt.1
}
