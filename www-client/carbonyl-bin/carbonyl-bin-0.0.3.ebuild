# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Chromium-based browser that runs in your terminal (binary release)"
HOMEPAGE="https://github.com/fathyb/carbonyl"
SRC_URI="https://github.com/fathyb/carbonyl/releases/download/v${PV}/carbonyl.linux-amd64.zip -> ${P}-amd64.zip"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip mirror"  # prestripped upstream binary; avoid mirroring GH assets

# Upstream notes these at runtime on Linux (see release notes)
# nss: SSL/certs, expat: XML, alsa-lib: audio, fontconfig: font config
RDEPEND="
  dev-libs/nss
  dev-libs/expat
  media-libs/alsa-lib
  media-libs/fontconfig
"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/carbonyl-${PV}"

QA_PREBUILT="*"

src_unpack() {
  unpack "${P}-amd64.zip"
}

src_install() {
  # Install the whole payload under /opt to keep the Chromium runtime together
  dodir /opt/${PN}
  insinto /opt/${PN}
  doins -r "${S}/"*

  # Launch wrapper
  newbin - carbonyl <<'EOF'
#!/bin/sh
exec /opt/carbonyl-bin/carbonyl "$@"
EOF

  # Docs / license if present in the archive
  if [[ -f "${S}/LICENSE" ]]; then
    dodoc "${S}/LICENSE"
  fi
  if [[ -f "${S}/README.md" ]]; then
    dodoc "${S}/README.md"
  fi
}

pkg_postinst() {
  einfo "Carbonyl is installed at /opt/${PN} with wrapper /usr/bin/carbonyl."
  einfo "Useful flags: --bitmap and --zoom (see: carbonyl --help)."
}

