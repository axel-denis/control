# Slskd

### Info
> "A modern client-server application for the Soulseek file-sharing network."

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`slskd.paths`:
| Name           | Description                                                  | Default                        |
| -------        | -----------------------------------------------------------  | ------------------------------ |
| default        | The main path of the app                                     | `<main path>/slskd`            |
| directories    | Path for Slskd media dirs. See more below.                   | `<main path>/<default>/media`  |
| data           | Path for Slskd appdata                                       | `<main path>/<default>/data`   |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `slskd.paths.default`
---
- `music` is not a regular path, it's an attribute set to mount many media points:
```nix
slskd.paths.directories = {
    mount1 = "/path1";
    mount2 = "/path2";
}
```
-> In the container:
/mount1
/mount2

`slskd.configuration`:
Variables passed as environment variables to slskd.

> [!CAUTION]
> - `SLSKD_SLSK_USERNAME` and `SLSKD_SLSK_USERNAME` are mandatory for slskd to start. Please refer to [slskd docs](https://github.com/slskd/slskd/blob/master/docs/config.md)

Example:
```nix
configuration = {
    SLSKD_SLSK_USERNAME = "username";
    SLSKD_SLSK_PASSWORD = "password";
};
```
---

### Example

Minimal example :
```nix
slskd = {
    enable = true;
    configuration = {
        SLSKD_SLSK_USERNAME = "username";
        SLSKD_SLSK_PASSWORD = "password";
    };
};
```

The above example enables Slskd, using [default](../defaults.md) values for port and location of the app data.

Complete example :
```nix
slskd = {
    enable = true;

    configuration = {
        SLSKD_SLSK_USERNAME = "username";
        SLSKD_SLSK_PASSWORD = "password";
        #...
    };

    subdomain = "slskd"; # -> slskd.yourdomain.com (if routing module enabled)
    port = 8080; # -> server_ip:8080 (if routing module NOT enabled)

    # if you must change the path, in most case you should only change paths.default and let the flake
    # handle the rest. This extensive example shows a more complex but complete configuration
    paths = {
        # if unset, would default to the global main path (ex. /control_appdata/slskd)
        default = "/mnt/my_other_disk/my_slskd";

        # if unset, would default to "<default>/media" -> /mnt/my_other_disk/my_slskd/media
        media = { main = "/mnt/music_disk/"; }; # useful if your media is on a separate disk

        # if unset, would default to "<default>/config" -> /mnt/my_other_disk/my_slskd/config
        data = "/mnt/music_disk/slskd_data"; # generally useless to set
    };
};
```
