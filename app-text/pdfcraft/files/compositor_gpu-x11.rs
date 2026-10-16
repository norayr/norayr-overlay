// X11-only Gentoo build: there is no Wayland compositor to probe.
// Let the application's normal GPU selection code choose an adapter.
pub(crate) fn compositor_gpu() -> Option<(u32, u32)> {
    None
}
