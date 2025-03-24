EAPI=8

inherit git-r3

DESCRIPTION="Heliko - a Pascal/Lazarus application"
HOMEPAGE="https://github.com/norayr/heliko"
EGIT_REPO_URI="https://github.com/norayr/heliko.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE=""

DEPEND="dev-lang/fpc
        dev-lang/lazarus"
RDEPEND="${DEPEND}"

# Lazarus system-wide path (used in Gentoo)
LAZARUS_PATH="/usr/share/lazarus"

src_compile() {
  local ARCH=$(uname -m)-linux
  local TMPDIR="${T}/units"

  mkdir -p "${TMPDIR}" || die "Failed to create unit output dir"

  fpc project1.lpr \
    -FU"${TMPDIR}" \
    -MObjFPC -Scgi -O1 -gl -vewnhi -l -Xs -Xg \
    -Fu"${LAZARUS_PATH}/components/lazutils" \
    -Fu"${LAZARUS_PATH}/components/synedit" \
    -Fu"${LAZARUS_PATH}/components/synedit/units/${ARCH}" \
    -Fu"${LAZARUS_PATH}/lcl/units/${ARCH}/" \
    -Fu"${LAZARUS_PATH}/lcl/units/${ARCH}/gtk2/" \
    -Fu"${LAZARUS_PATH}/packager/units/${ARCH}/" \
    -Fu. -oheliko \
    -dLCL -dLCLgtk2 || die "fpc build failed"
}


src_install() {
  dobin heliko
  dodoc readme.md* LICENSE heliko.txt
}
