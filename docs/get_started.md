# Getting started

## Before we start
It's important to understand the philosophy behind this flake: it aims to provides the **simplest** configuration possible for setting up a homeserver.

That's why this flake can run on it's own with almost no configuration. You just have to enable desired services and tools (ex. `immich.enable = true;`) and you're good to go.

However, if you wish to customize a bit your server (choose where the data is stored, set your domain name and subdomains...), this flake also provide you with **a lot of simple options** to do so.

> [!IMPORTANT] 
> You just have to keep in mind that all of those options are **not required to be set if not specifically needed**. Don't let yourself be overwhelmed by all the options specified in the other documentation pages.

## Our first apps
Let's enable our first apps by creating a simple config file that imports this flake (check the installation guide):
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    terminal.enableOhMyZsh = true;
  }
}
```
Of course, apply this by using `sudo nixos-rebuild switch`.<br>
With this first simple setup, we already have a brand new terminal with Oh My Zsh enabled, and two running apps.

Without additionnal configuration, apps run on lan (no domain name, just ip:port). You can check the default ports for each app [here](./web_options.md#serviceport) (`<service>.port` section).

In our case, we can access Immich on `0.0.0.0:10001` and jellyfin on `0.0.0.0:10002` (change `0.0.0.0` by your server ip)

## Customize data storage
###### keep in mind that we are now in the "optional" field.

### Move one app
Sometime, we would like to have some app's data stored in another disk or location. You can do so by editing `<app>.paths.default`:
```nix
{ homeserver, ...}
{
  homeserver = {
    jellyfin.enable = true;
    terminal.enableOhMyZsh = true;

    immich = {
        enable = true;
        paths.default = "/other_disk/immich";
    };
  }
}
```
Here, all the immich data will be under that new path, instead of the global default path.

<details>
<summary>Some apps allow to customize storage even further. Expand to see.</summary>

You can check the documentation of each module to see which paths can be customizable. Let's take [Jellyfin](../docs/perModule/jellyfin.md) for this example.

Jellyfin allows us to customize
- `media` -> where medias are stored
- `config` -> where the app store it's data

It's a common use case scenario to store the media on a different disk:
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    terminal.enableOhMyZsh = true;
    jellyfin = {
      enable = true;
      paths.media = "/other_disk";
    };
  }
}
```
With this setup, the media will be stored on the specified disk, while `path.config` will stay at the default location.
</details>

### Move all apps
If needed, we can directly change the default path for all apps in one go:
```nix
{ homeserver, ...}
{
  homeserver = {
    defaultPath = "/other_disk"; # if not specified, default to /homeserverdata

    immich.enable = true;
    jellyfin.enable = true;
    terminal.enableOhMyZsh = true;
  }
}
```
