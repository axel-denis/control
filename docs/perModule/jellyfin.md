# Jellyfin
###### The Free Software Media System.

### Info
> "Jellyfin enables you to collect, manage, and stream your media. Run the Jellyfin server on your system and gain access to the leading free-software entertainment system"

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`jellyfin.paths`:
| Name    | Description                                                 | Default                        |
| ------- | ----------------------------------------------------------- | ------------------------------ |
| default | The main path of the app                                    | `<main path>/jellyfin`         |
| media   | Path for Jellyfin media (movies, music...). See more below. | `<main path>/<default>/media`  |
| config  | Path for Jellyfin appdata (config)                          | `<main path>/<default>/config` |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `jellyfin.paths.default`
---
- `media` is not a regular path, it's an attribute set to mount many media points:
```nix
jellyfin.paths.media = {
    mount1 = "/path1";
    mount2 = "/path2";
}
```
-> In the container:
/media/mount1
/media/mount2

---

### Example

Minimal example :
```nix
jellyfin.enable = true;
```

This example enables Jellyfin, using [default](../defaults.md) values for port and location of the app data.

Complete example :
```nix
jellyfin = {
    enable = true;

    subdomain = "movies"; # -> movies.yourdomain.com (if routing module enabled)
    port = 8080; # -> server_ip:8080 (if routing module NOT enabled)

    # if you must change the path, in most case you should only change paths.default and let the flake
    # handle the rest. This extensive example shows a more complex but complete configuration
    paths = {
        # if unset, would default to the global main path (ex. /control_appdata/jellyfin)
        default = "/mnt/my_other_disk/my_jellyfin";

        # if unset, would default to "<default>/media" -> /mnt/my_other_disk/my_jellyfin/media
        media = "/mnt/movies_disk/"; # useful if your media is on a separate disk

        # if unset, would default to "<default>/config" -> /mnt/my_other_disk/my_jellyfin/config
        config = "/mnt/movies_disk/jellyfin_data"; # generally useless to set
    };
};
```
