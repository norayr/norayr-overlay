EAPI=8

inherit git-r3 desktop

DESCRIPTION="Modern rewrite of Tomboy Notes using FreePascal and Lazarus"
HOMEPAGE="https://github.com/tomboy-notes/tomboy-ng"
EGIT_REPO_URI="https://github.com/tomboy-notes/tomboy-ng.git"
EGIT_COMMIT="v0.42"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc"
IUSE=""

DEPEND="dev-lang/fpc
        dev-lang/lazarus"
RDEPEND="${DEPEND}"

LAZARUS_PATH="/usr/share/lazarus"

src_compile() {
  cd source || die "source/ directory not found"

  local ARCH=$(uname -m)-linux
  local TMPDIR="${T}/units"
  mkdir -p "${TMPDIR}" || die "Failed to create unit output dir"

  fpc Tomboy_NG.lpr \
    -MObjFPC -Scgi -O1 -gl -vewnhi -l -Xs -Xg \
    -FU"${TMPDIR}" \
    -Fu"${LAZARUS_PATH}/components/lazutils" \
    -Fu"${LAZARUS_PATH}/components/synedit" \
    -Fu"${LAZARUS_PATH}/components/synedit/units/${ARCH}" \
    -Fu"${LAZARUS_PATH}/lcl/units/${ARCH}/" \
    -Fu"${LAZARUS_PATH}/lcl/units/${ARCH}/gtk2/" \
    -Fu"${LAZARUS_PATH}/packager/units/${ARCH}/" \
  -Fu"${LAZARUS_PATH}/components/printer4lazarus" \
    -Fu. -otomboy-ng \
    -dLCL -dLCLgtk2 || die "fpc build failed"
}

src_install() {
  cd source || die
  dobin tomboy-ng

  # .desktop and icon
  insinto /usr/share/applications
  doins ../glyphs/tomboy-ng.desktop

  insinto /usr/share/pixmaps
  doins ../glyphs/icons/hicolor/256x256/apps/tomboy-ng.png

  dodoc ../README.md
}
