# My Gentoo Overlay

This is a personal Gentoo overlay containing custom ebuilds.

## Adding the Overlay

To add this overlay to your system, use `eselect-repository` (recommended):

```bash
eselect repository add norayr-overlay git https://github.com/norayr/norayr-overlay.git


Alternatively, you can add it manually to `/etc/portage/repos.conf`

```
[my-overlay]
location = /var/db/repos/norayr-overlay
sync-type = git
sync-uri = https://github.com/norayr/norayr-overlay.git
priority = 50
```

and then sync the overlay

```
emaint sync -r my-overlay
```

