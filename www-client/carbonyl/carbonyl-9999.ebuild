# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Chromium-based browser that runs in your terminal (build from source)"
HOMEPAGE="https://github.com/fathyb/carbonyl"
EGIT_REPO_URI="https://github.com/fathyb/carbonyl.git"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test mirror strip"

BDEPEND="
  dev-vcs/git
  dev-lang/python:3.11[sqlite]
  sys-apps/coreutils
  dev-util/ccache
"
RDEPEND="
  dev-libs/nss
  dev-libs/expat
  media-libs/alsa-lib
  media-libs/fontconfig
"

# Correct source directory for git-r3 live ebuilds
S="${WORKDIR}/${P}"

pkg_pretend() {
  ewarn "This ebuild downloads and builds Chromium via upstream scripts."
  ewarn "Expect ~100 GB disk usage and a long build."
  ewarn "Building arm64 targets on Linux requires an amd64 builder (cross via GN)."
}

src_unpack() {
  git-r3_src_unpack
}

_gen_gn_args() {
  local target="amd64"
  case ${ARCH} in
    amd64) target="amd64" ;;
    arm64) target="arm64" ;;
    *) die "Unsupported ARCH: ${ARCH}" ;;
  esac

  cat > "${T}/args.gn" <<-EOF
import("//carbonyl/src/browser/args.gn")
$( [[ ${target} == arm64 ]] && echo 'target_cpu = "arm64"' )
cc_wrapper = "env CCACHE_SLOPPINESS=time_macros ccache"
is_debug = false
symbol_level = 0
is_official_build = true
EOF
}

src_prepare() {
  default
  einfo "Syncing Chromium (this is large)..."
  ./scripts/gclient.sh sync || die "gclient sync failed"

  einfo "Applying patches..."
  ./scripts/patches.sh apply || die "patches.sh failed"

  _gen_gn_args
}

src_configure() {
  einfo "Configuring GN..."
  ./scripts/gn.sh args out/Default < "${T}/args.gn" || die "gn args failed"
}

src_compile() {
  einfo "Building (this will take a long time)..."
  ./scripts/build.sh Default || die "build failed"
}

src_install() {
  local outdir="${S}/out/Default"

  insinto /opt/${PN}
  doins -r \
    "${outdir}/headless_shell" \
    "${outdir}/icudtl.dat" \
    "${outdir}/libEGL.so" \
    "${outdir}/libGLESv2.so" \
    "${outdir}/v8_context_snapshot.bin"

  # Ensure the runtime is executable
  fperms +x /opt/${PN}/headless_shell

  # Wrapper
  newbin - carbonyl <<-'EOF'
#!/bin/sh
exec /opt/carbonyl/headless_shell "$@"
EOF

  # Best-effort docs
  dodoc readme.md license.md changelog.md 2>/dev/null || true
}
