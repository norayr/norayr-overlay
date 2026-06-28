EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="GTK2 web-comic reader written in Free Pascal and Lazarus"
HOMEPAGE="https://github.com/maemo-leste-extras/comics-daily"
EGIT_REPO_URI="https://github.com/maemo-leste-extras/comics-daily.git"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND="
dev-lang/fpc
dev-lang/lazarus[gui,gtk2]
"
DEPEND="
dev-libs/openssl:=
x11-libs/gtk+:2
x11-libs/libX11
"
RDEPEND="${DEPEND}"

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

fpc project1.lpr \
	-FU"${T}/units" \
	-Xs -Xg \
	-MObjFPC -Scgi \
	-O1 -gl \
	-vewnhi -l \
	-Fu"${lazarus_path}/components/lazutils" \
	-Fu"${lazarus_path}/lcl/units/${fpc_target}" \
	-Fu"${lazarus_path}/lcl/units/${fpc_target}/gtk2" \
	-Fu"${lazarus_path}/packager/units/${fpc_target}" \
	-Fu. \
	-ocomics-daily \
	-dLCL -dLCLgtk2 ||
	die "fpc build failed"
```

}

src_install() {
dobin comics-daily

```
newicon -s 48 comics-daily.png comics-daily.png

make_desktop_entry \
	comics-daily \
	"Comics Daily" \
	comics-daily \
	"Network;News;"

local f
for f in comics-daily-insect*.png; do
	[[ -f ${f} ]] || continue

	insinto /usr/share/pixmaps/comics-daily
	doins "${f}"
done

dodoc readme.md
```

}

