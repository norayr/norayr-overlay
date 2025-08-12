# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Live ebuild using upstream scripts to build Chromium + Carbonyl runtime.
# WARNING: ~100GB disk, long build, network during src_* phases.

inherit git-r3

DESCRIPTION="Chromium-based browser that runs in your terminal (build from source)"
HOMEPAGE="https://github.com/fathyb/carbonyl"
EGIT_REPO_URI="https://github.com/fathyb/carbonyl.git"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test mirror strip"

# We mostly rely on Chromium's own toolchain downloaded by depot_tools.
# Some host tools we provide from Gentoo to keep things saner.
BDEPEND="
  dev-vcs/git
  dev-lang/python:3.11[sqlite]
  sys-apps/coreutils
  sys-devel/ccache
"
# Runtime libs are same as -bin variant; Chromium will link plenty of its own.
RDEPEND="
  dev-libs/nss
  dev-libs/expat
  media-libs/alsa-lib
  media-libs/fontconfig
"

S="${WORKDIR}/${PN}"

pkg_pretend() {
  ewarn "This ebuild downloads and builds Chromium via upstream scripts."
  ewarn "Expect ~100 GB disk usage and a long build."
  ewarn "Building arm64 targets on Linux requires an amd64 builder (cross via GN)."
}

src_unpack() {
  git-r3_src_unpack
}

# Helper: write GN args that upstream requests
_gen_gn_args() {
  local target="amd64"
  case ${ARCH} in
    amd64) target="amd64" ;;
    arm64) target="arm64" ;;  # cross-build on amd64 host is recommended upstream
    *) die "Unsupported ARCH: ${ARCH}" ;;
  esac

  cat > "${T}/args.gn" <<-EOF
import("//carbonyl/src/browser/args.gn")
# uncomment for arm64 builds
$( [[ ${target} == arm64 ]] && echo 'target_cpu = "arm64"' )
# use ccache if available
cc_wrapper = "env CCACHE_SLOPPINESS=time_macros ccache"
# release-ish
is_debug = false
symbol_level = 0
is_official_build = true
EOF
}

src_prepare() {
  default

  # Fetch Chromium and deps (network)
  einfo "Syncing Chromium (this is large)..."
  ./scripts/gclient.sh sync || die "gclient sync failed"

  # Apply Carbonyl patches to Chromium
  einfo "Applying patches..."
  ./scripts/patches.sh apply || die "patches.sh failed"

  _gen_gn_args
}

src_configure() {
  # Feed our GN args into upstream wrapper
  einfo "Configuring GN..."
  ./scripts/gn.sh args out/Default < "${T}/args.gn" || die "gn args failed"
}

src_compile() {
  # Build Chromium-based runtime + bundles (Rust lib is built as part of this)
  einfo "Building (this will take a long time)..."
  ./scripts/build.sh Default || die "build failed"
}

src_install() {
  # Upstream outputs:
  #  out/Default/headless_shell + icudtl.dat + libEGL.so + libGLESv2.so + v8_context_snapshot.bin
  # Package like upstream binary zips: keep together under /opt/${PN}
  local outdir="${S}/out/Default"

  dodir /opt/${PN}
  insinto /opt/${PN}
  doins -r \
    "${outdir}/headless_shell" \
    "${outdir}/icudtl.dat" \
    "${outdir}/libEGL.so" \
    "${outdir}/libGLESv2.so" \
    "${outdir}/v8_context_snapshot.bin" 2>/dev/null || true

  # Upstream packages a 'carbonyl' launcher; emulate it by calling headless_shell
  # The binary is built with Carbonyl patches, so invoking headless_shell is enough.
  newbin - carbonyl <<-'EOF'
#!/bin/sh
# Simple wrapper to the patched Chromium headless shell
exec /opt/carbonyl/headless_shell "$@"
EOF

  dodoc readme.md license.md changelog.md 2>/dev/null || true
}
