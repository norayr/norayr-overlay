EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="Minimalistic RSS reader written in Pascal using Lazarus"
HOMEPAGE="https://codeberg.org/norayr/tomar"
EGIT_REPO_URI="https://codeberg.org/norayr/tomar.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="video"

BDEPEND="
dev-lang/fpc
dev-lang/lazarus[gui,gtk2]
"
DEPEND="
dev-libs/openssl:=
x11-libs/gtk+:2
"
RDEPEND="
${DEPEND}
video? (
media-video/mpv
net-misc/yt-dlp
)
"

src_compile() {
local lazarus_path="/usr/share/lazarus"
local target_cpu target_os fpc_target

```
target_cpu=$(fpc -iTP) ||
	die "Could not determine the FPC target CPU"

target_os=$(fpc -iTO) ||
	die "Could not determine the FPC target OS"

fpc_target="${target_cpu}-${target_os}"

[[ -d ${lazarus_path}/lcl/units/${fpc_target}/gtk2 ]] ||
	die "Lazarus GTK2 units not found for ${fpc_target}"

mkdir -p "${T}/units" || die

fpc rssreader.lpr \
	-FU"${T}/units" \
	-MObjFPC -Scgi -O1 -gl -vewnhi -l -Xs -Xg \
	-Fu"${lazarus_path}/components/lazutils" \
	-Fu"${lazarus_path}/lcl/units/${fpc_target}" \
	-Fu"${lazarus_path}/lcl/units/${fpc_target}/gtk2" \
	-Fu"${lazarus_path}/packager/units/${fpc_target}" \
	-Fu"${lazarus_path}/components/turbopower_ipro/units/${fpc_target}/gtk2" \
	-Fu"${lazarus_path}/components/turbopower_ipro" \
	-Fu. \
	-otomar \
	-dLCL -dLCLgtk2 ||
	die "fpc build failed"
```

}

src_install() {
dobin tomar

```
newicon -s 48 icon/receiver_48x48.png tomar.png
make_desktop_entry \
	tomar \
	"Tomar RSS Reader" \
	tomar \
	"Network;News;"

dodoc readme.md
```

}

