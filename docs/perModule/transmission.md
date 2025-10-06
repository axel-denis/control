# Transmission

### Info
> "A Fast, Easy and Free Bittorrent Client for macOS, Windows and Linux"

> [!NOTE]
> This container is a [variant](https://github.com/haugene/docker-transmission-openvpn) of the official Transmission created by [Haugene](https://github.com/haugene/).<br>
> It only runs when an openvpn connection is active (thus preventing you from seeding when not protected).
> Please check the [repo](https://github.com/haugene/docker-transmission-openvpn) for more info.

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`transmission.environmentFile`: (required)
Environment file to configure transmission-openvpn. Please check the [official repo](https://github.com/haugene/docker-transmission-openvpn) for docs.

`transmission.paths`:
| Name     | Description                            | Default                          |
| -------- | -------------------------------------- | -------------------------------- |
| default  | The main path of the app               | `<main path>/transmission`       |
| download | Path for Transmission downloads        | `<main path>/<default>/download` |
| config   | Path for Transmission appdata (config) | `<main path>/<default>/config`   |

- `<main path>` - Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `transmission.paths.default`

---

### Example

Minimal example :
This example enables Transmission, using [default](../defaults.md) values for port and location of the app data.
```nix
transmission = {
    enable = true;
    environmentFile = "./transmissionEnv";
};
```
