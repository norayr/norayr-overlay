EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="GTK2 image editor that applies HALD CLUTs to photographs"
HOMEPAGE="https://codeberg.org/norayr/chromatika_fpc"
EGIT_REPO_URI="https://codeberg.org/norayr/chromatika_fpc.git"
EGIT_BRANCH="main"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND="
	dev-lang/fpc
	dev-lang/lazarus[gui,gtk2]
"
DEPEND="
	x11-libs/gtk+:2
	x11-libs/libX11
"
RDEPEND="${DEPEND}"

src_compile() {
	local target_cpu target_os fpc_target
	local lazarus_path="/usr/share/lazarus"

	target_cpu=$(fpc -iTP) ||
		die "Could not determine the FPC target CPU"
	target_os=$(fpc -iTO) ||
		die "Could not determine the FPC target OS"
	fpc_target="${target_cpu}-${target_os}"

	[[ -d ${lazarus_path}/lcl/units/${fpc_target}/gtk2 ]] ||
		die "Lazarus GTK2 units not found for ${fpc_target}"
	[[ -d ${lazarus_path}/components/multithreadprocs ]] ||
		die "Lazarus multithreadprocs component not found"

	emake \
		ARCH="${fpc_target}" \
		LAZARUS="${lazarus_path}" \
		FPC=fpc
}

src_install() {
	local f source
	local -a hald_files=(
		chrome.png
		warm.png
		everyday.png
		landscape.png
	)

	dobin chromatika

	domenu chromatika.desktop
	newicon assets/icon/chromatika_48x48.png chromatika.png

	if [[ -f assets/color_checker.png ]]; then
		insinto /usr/share/chromatika/assets
		doins assets/color_checker.png
	fi

	insinto /usr/share/chromatika/hald
	for f in "${hald_files[@]}"; do
		if [[ -f assets/${f} ]]; then
			source="assets/${f}"
		elif [[ -f hald/${f} ]]; then
			source="hald/${f}"
		else
			die "Required HALD CLUT not found: ${f}"
		fi

		doins "${source}"
	done

	for f in README.md README readme.md readme; do
		[[ -f ${f} ]] && dodoc "${f}"
	done
}
