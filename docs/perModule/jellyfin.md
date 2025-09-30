# Jellyfin
###### The Free Software Media System.

### Info
> Jellyfin enables you to collect, manage, and stream your media. Run the Jellyfin server on your system and gain access to the leading free-software entertainment system

### Options
`jellyfin.<option>`
| Option name | Description       |
| ----------- | ----------------- |
| enable      | Enable Jellyfin   |
| version[^1] | Container version |
| subdomain   | App subdomain     |
| ----------- | ----------------- |
| ----------- | ----------------- |
| ----------- | ----------------- |
| ----------- | ----------------- |

---

### Example

Minimal example :
```nix
jellyfin.enable = true;
```

This example enables Jellyfin, using [default](../defaults.md) values for port and location of the app data.

---

> [!IMPORTANT]
> For wake on lan to receive your requests, your router needs to be properly configured to let [magic packets](https://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet) in. This configuration differs from router to router but generally is just an option to enable.

> [!WARNING]
> Some motherboards configure wake on lan from BIOS/UEFI. This makes this setting irrelevant. It's advised to check your motherboard manual or options and configure wake on lan directly on it.

> [!TIP]
> Learn about wake on lan on [wikipedia](https://en.wikipedia.org/wiki/Wake-on-LAN).

