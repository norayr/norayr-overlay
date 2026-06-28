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
local lazarus_config="${T}/lazarus"

```
mkdir -p "${lazarus_config}" || die

lazbuild \
	--primary-config-path="${lazarus_config}" \
	--widgetset=gtk2 \
	--build-all \
	project1.lpi ||
	die "lazbuild failed"
```

}

src_install() {
newbin project1 comics-daily

```
insinto /usr/share/pixmaps
doins comics-daily.png

make_desktop_entry \
	comics-daily \
	"Comics Daily" \
	comics-daily \
	"Graphics;Viewer;"

dodoc readme.md
```

}

