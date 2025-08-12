# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Chromium-based browser that runs in your terminal (prebuilt binaries)"
HOMEPAGE="https://github.com/fathyb/carbonyl"
LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip mirror"

# Upstream publishes per-arch zips for v0.0.3
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

# Archive layout is flat; keep everything together under /opt to avoid ELF RPATH pain.
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
  # Put payload into /opt/${PN}
  dodir /opt/${PN}
  insinto /opt/${PN}
  doins -r "${S}/"*

  # Wrapper
  newbin - carbonyl <<-'EOF'
#!/bin/sh
exec /opt/carbonyl-bin/carbonyl "$@"
EOF

  # Docs if present
  [[ -f "${S}/LICENSE"    ]] && dodoc "${S}/LICENSE"
  [[ -f "${S}/README.md"  ]] && dodoc "${S}/README.md"
}

pkg_postinst() {
  einfo "Installed to /opt/${PN}, wrapper at /usr/bin/carbonyl."
  einfo "Try: carbonyl --bitmap --zoom 2 https://example.org"
}

