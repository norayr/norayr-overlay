# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Chromium-based browser that runs in your terminal (prebuilt binaries)"
HOMEPAGE="https://github.com/fathyb/carbonyl"
LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip mirror"

SRC_URI="
  amd64? ( https://github.com/fathyb/carbonyl/releases/download/v${PV}/carbonyl.linux-amd64.zip -> ${P}-amd64.zip )
  arm64? ( https://github.com/fathyb/carbonyl/releases/download/v${PV}/carbonyl.linux-arm64.zip -> ${P}-arm64.zip )
"

RDEPEND="
  dev-libs/nss
  dev-libs/expat
  media-libs/alsa-lib
  media-libs/fontconfig
"
BDEPEND="app-arch/unzip"

S="${WORKDIR}"
QA_PREBUILT="*"

src_unpack() {
  if use amd64 ; then
    unpack "${P}-amd64.zip"
  elif use arm64 ; then
    unpack "${P}-arm64.zip"
  else
    die "Unsupported keyword"
  fi
}

src_install() {
  # Find the versioned folder from the zip (e.g., carbonyl-0.0.3)
  local d
  d=( "${S}"/carbonyl-* )
  [[ -d ${d[0]} ]] || die "Couldn't find unpacked carbonyl-* directory"

  # Flatten into /opt/${PN}
  insinto /opt/${PN}
  doins -r "${d[0]}/"*

  # Ensure the launcher is executable
  fperms +x /opt/${PN}/carbonyl

  # Wrapper
  newbin - carbonyl <<-'EOF'
#!/bin/sh
exec /opt/carbonyl-bin/carbonyl "$@"
EOF

  # Docs if present
  [[ -f "${d[0]}/LICENSE"   ]] && dodoc "${d[0]}/LICENSE"
  [[ -f "${d[0]}/README.md" ]] && dodoc "${d[0]}/README.md"
}

pkg_postinst() {
  einfo "Installed to /opt/${PN}, wrapper at /usr/bin/carbonyl."
  einfo "Try: carbonyl --bitmap --zoom 2 https://example.org"
}
