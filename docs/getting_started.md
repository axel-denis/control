# Getting started

If not installed, please [install](./install_guide.md) this flake.

## Before we start
It's important to understand the philosophy behind this flake: it aims to provides the **simplest** configuration possible for setting up a homeserver.

That's why this flake can run on it's own with almost no configuration. You just have to enable desired services and tools (ex. `immich.enable = true;`) and you're good to go.

However, if you wish to customize a bit your server (choose where the data is stored, set your domain name and subdomains...), this flake also provide you with **a lot of simple options** to do so.

> [!IMPORTANT] 
> You just have to keep in mind that all of those options are **not required to be set if not specifically needed**. Don't let yourself be overwhelmed by all the options specified in the other documentation pages.

<br>

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

<br>

## Customize data storage
> [!IMPORTANT]
> keep in mind that we are now in the "optional" field.

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
> [!TIP]
> Those detailed path config are not the same from one module to another. Be sure to check the documentation for each module.

---

</details>

<br>

> [!WARNING]
> Changing an app's storage space does not automatically move existing data. Be sure to move it yourself if you're not setting up the app for the first time.

<br>

## Add some tools
Not everything is a webservice. We also provide some tools.

A cool quality of life is the [terminal](./perModule/terminal.md) module, that allows us to enable [Oh My ZSH](https://ohmyz.sh/). (We already enabled it earlier)

Another one is [hdd-spindown](./perModule/hdd-spindown.md), through which we can define a set amount of time after what HDD disks stop spinning if idle. This is very common to reduce noise and save power.

Let's add them:
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    terminal.enableOhMyZsh = true;
    hdd-spindown.enable = true; # Default time is 20min
  }
}
```

Please check the documentation for these two modules if you wish to customize them further !

<br>

## Customize network
If your homeserver is accessible through internet, you can bind a domain and subdomains to it.<br>
We will not cover the "how to get a domain here", and proceed like you already have one.

Let's enable the routing module:

```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    terminal.enableOhMyZsh = true;

    routing = {
      enable = true;
      domain = "yourdomain.com";
      letsencrypt = {
        enable = true;
        email = "email.for.letsencrypt@example.com";
      };
    };
  }
}
```
This configuration contains some new options, let's get through them.

`domain` is self explanatory. All enabled apps will be binded to appname.yourdomain.com.

`letsencrypt` enables https, getting certificates from [Let's Encrypt](https://letsencrypt.org/). Those certificates will be automatically managed (ACME). The email is an email where you could be contacted for informations relative to your certificate (never received one, but it's there).
> [!IMPORTANT]
> It's really recommanded for your server to use https, and Let's Encrypt ACME provides a nice, free and NixOS compliant way to do it. [Let's Encrypt ToS](https://letsencrypt.org/repository/) has to be accepted.<br>
> This flake does not provide a way to import custom certificates (if you already have some) for now. But that's should be some easy modifications if you want to contribute :smile:

With router enabled, all usual containers ports are closed (you can't access by <your_ip>:port anymore). **Only ports 80 (http) and 443 (https) are opened.** If you open those ports on your router, and add proper dns redirection through your dns provider, you should be good to go !

> [!TIP]
> Apps default subdomain are their name. Ex. `immich.yourdomain.com`, `jellyfin.yourdomain.com`...
>
> A lot more configuration options can be managed. Please check the complete [routing module doc](../docs/perModule/routing.md).
