# Navidrome
###### Your Personal Streaming Service.

### Info
> "Navidrome allows you to enjoy your music collection from anywhere"

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`navidrome.paths`:
| Name    | Description                                                  | Default                        |
| ------- | -----------------------------------------------------------  | ------------------------------ |
| default | The main path of the app                                     | `<main path>/navidrome`        |
| music   | Path for Navidrome media (movies, music...). See more below. | `<main path>/<default>/media`  |
| data    | Path for Navidrome appdata                                     | `<main path>/<default>/data`   |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `navidrome.paths.default`
---
- `music` is not a regular path, it's an attribute set to mount many media points:
```nix
navidrome.paths.music = {
    mount1 = "/path1";
    mount2 = "/path2";
}
```
-> In the container:
/music/mount1
/music/mount2


`navidrome.configuration`:
Variables passed as environment variables to navidrome.

Example:
```nix
configuration = {
    ND_LOGLEVEL = "info";
};
```

---

### Example

Minimal example :
```nix
navidrome.enable = true;
```

The above example enables Navidrome, using [default](../defaults.md) values for port and location of the app data.

Complete example :
```nix
navidrome = {
    enable = true;

    configuration = {
        ND_LOGLEVEL = "info";
    };

    subdomain = "music"; # -> music.yourdomain.com (if routing module enabled)
    port = 8080; # -> server_ip:8080 (if routing module NOT enabled)

    # if you must change the path, in most case you should only change paths.default and let the flake
    # handle the rest. This extensive example shows a more complex but complete configuration
    paths = {
        # if unset, would default to the global main path (ex. /control_appdata/navidrome)
        default = "/mnt/my_other_disk/my_navidrome";

        # if unset, would default to "<default>/media" -> /mnt/my_other_disk/my_navidrome/media
        media = { main = "/mnt/music_disk/"; }; # useful if your media is on a separate disk

        # if unset, would default to "<default>/config" -> /mnt/my_other_disk/my_navidrome/config
        data = "/mnt/music_disk/navidrome_data"; # generally useless to set
    };
};
```
