# norayr's gentoo overlay

this gentoo overlay contains ebuilds to build

* lagrange

## adding the overlay

to add this overlay to your system, use `eselect-repository` (recommended):

```bash
eselect repository add norayr-overlay git https://github.com/norayr/norayr-overlay.git
mkdir -p /var/db/repos/norayr-overlay
emerge --sync norayr-overlay
```

Alternatively, you can add it manually to `/etc/portage/repos.conf` directory as `norayr-overlay.conf`:

```
[norayr-overlay]
location = /var/db/repos/norayr-overlay
sync-type = git
sync-uri = https://github.com/norayr/norayr-overlay.git
priority = 50
```

and then sync the overlay

```
emaint sync -r my-overlay
```

