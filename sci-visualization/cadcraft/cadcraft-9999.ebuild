# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.90.0"

inherit cargo desktop git-r3

DESCRIPTION="CAD drawing and drafting software"
HOMEPAGE="https://getartcraft.com/apps/${PN} https://github.com/storytold/${PN}"
EGIT_REPO_URI="https://github.com/storytold/${PN}.git"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS=""
IUSE="+cli accessibility"
RESTRICT="test"

DEPEND="
	media-libs/vulkan-loader
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	virtual/libudev
"
RDEPEND="${DEPEND}"
BDEPEND="dev-util/pkgconf"

src_unpack() {
	git-r3_src_unpack

	# Only enable eframe's X11 window backend. Patch before cargo_live_src_unpack
	# so Cargo can update the lockfile and vendor the correct dependency set.
	local app_manifest="${S}/apps/${PN}/Cargo.toml"
	[[ -f ${app_manifest} ]] || die "missing application Cargo.toml"
	grep -Fq '"wayland", "x11"' "${app_manifest}" || die "upstream window backend features changed"
	sed -i 's/"wayland", "x11"/"x11"/' "${app_manifest}" || die

	# Disable the Linux AT-SPI / AccessKit integration unless explicitly requested.
	# This removes accesskit_unix and its atspi-common dependency, without
	# affecting the X11 window backend. Put this before cargo_live_src_unpack.
	if ! use accessibility; then
		grep -Fq '"accesskit"' "${app_manifest}" || die "upstream AccessKit features changed"
		sed -i 's/"accesskit", //' "${app_manifest}" || die

		# Cargo unifies crate features across the dependency graph. Some
		# applications also enable AccessKit from their internal UI crate.
		# Removing it only from the executable manifest is insufficient.
		local ui_manifest="${S}/crates/ui-egui/Cargo.toml"
		if [[ -f ${ui_manifest} ]] && grep -Fq '"accesskit"' "${ui_manifest}"; then
			sed -i -e 's/"accesskit", //g' -e 's/, "accesskit"//g' \
				"${ui_manifest}" || die
		fi
	fi

	cargo_live_src_unpack
}

src_configure() {
	local packages=( -p "${PN}" )
	use cli && packages+=( -p "${PN}-cli" )
	cargo_src_configure "${packages[@]}" --frozen
}

src_install() {
	dobin "$(cargo_target_dir)/${PN}"
	if use cli; then
		dobin "$(cargo_target_dir)/${PN}-cli"
	fi

	make_desktop_entry "${PN}" "CADCraft" "${PN}" "Graphics;2DGraphics;"
	einstalldocs
}
