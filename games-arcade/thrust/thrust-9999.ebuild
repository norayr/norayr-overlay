# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Thrust 0.89f, a cave-flying game inspired by the C64 original"
HOMEPAGE="https://codeberg.org/norayr/thrust https://github.com/norayr/thrust"
EGIT_REPO_URI="https://codeberg.org/norayr/thrust.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~x86 ~x86_64 ~arm ~arm64 ~ppc ~ppc64 ~riscv"
IUSE="sound x ggi svga netpbm pbm"

REQUIRED_USE="|| ( x ggi svga )"

RDEPEND="
	x? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libICE
		x11-libs/libSM
	)
	ggi? ( media-libs/libggi )
	svga? ( media-libs/svgalib )
	netpbm? ( media-libs/netpbm )
	pbm? ( media-libs/netpbm )
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
"

src_prepare() {
	default

	# Only regenerate if this is a raw checkout without configure.
	if [[ ! -x configure && -f configure.ac ]] ; then
		eautoreconf
	fi
}

src_configure() {
	local myconf=(
		$(use_enable sound)
		$(use_with x)
		$(use_with ggi)
		$(use_with svga)
		$(use_with netpbm)
		$(use_with pbm)
		--sharedstatedir="${EPREFIX}/var/lib/${PN}"
	)

	econf "${myconf[@]}"
}

src_install() {
	default

	# The upstream binary installs as xthrust.
	dosym xthrust /usr/bin/thrust

	keepdir /var/lib/${PN}
}

pkg_postinst() {
	elog "If you enabled USE=sound, this old game uses OSS /dev/dsp."
	elog "Your kernel should have ALSA OSS emulation:"
	elog "  CONFIG_SND_OSSEMUL=y"
	elog "  CONFIG_SND_PCM_OSS=m or y"
	elog "  CONFIG_SND_MIXER_OSS=m or y"
	elog ""
	elog "After booting that kernel, try:"
	elog "  modprobe snd-pcm-oss snd-mixer-oss"
	elog "  ls -l /dev/dsp"
}

