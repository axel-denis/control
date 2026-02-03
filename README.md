<p align="center">
  <img src="./docs/assets/control_logo.svg" style="width:75%;" />
</p>
<br>

# Control; An easy NixOS homeserver
[Get started.](#ready-to-dive-in--check-one-of-the-guides)

Despite being one of the best linux distribution choice to setup a server, NixOS can be tough for beginners, which makes it rarely used in practice.<br>
**This repo aims to fix this !**

This package does all the heavy lifting for you, and let you with a "can't be simpler" configuration. See yourself:

```nix
{ control, ...}

{
  control = {
    jellyfin.enable = true; # self hosted netflix
    immich.enable = true; # self hosted google photos
    psitransfer.enable = true; # self hosted wetransfer
    # ...there's more
  };
}
```

**That's all you need to have a control hosting Jellyfin, Immich and Psitransfer running on your server !**

---

Have a domain and want your server accessible through the web ? Just enable it:

```nix
routing.enable = true;
routing = {
  domain = "yourdomain.com";
  letsencrypt.enable = true; # enables https
  letsencrypt.email = "letsencrypt.email@email.com"
};
```
You can now access
- [https://jellyfin.yourdomain.com](https://www.youtube.com/watch?v=E4WlUXrJgy4)
- [https://immich.yourdomain.com](https://www.youtube.com/watch?v=E4WlUXrJgy4)
- [https://psitransfer.yourdomain.com](https://www.youtube.com/watch?v=E4WlUXrJgy4)
  <sub><br>... and other enabled services as well</sub>

> [!TIP]
> Getting https certificates configuration can't be easier as we support [Let's Encrypt](https://letsencrypt.org/).

---

For a bit more customized configuration, you can use simple properties, *standardized accross modules*:
```nix
jellyfin = {
  enable = true;
  paths.default = "/another/place";  # where you store the app data (ex. movies)
  subdomain = "movies";              # -> movies.yourdomain.com
  port = 8080;                       # useful to customise if you don't use routing
  version = "...";                   # specific docker image version
};
```

> [!NOTE]
> The same properties can be used for other webservices (Immich, GitLab, PsiTransfer...) as well.

---

<br>

*Oh, and we also provide tools like terminal configuration [(oh my zsh)](https://ohmyz.sh/) and hdd-spindown. You'll see that later in the docs* :)

## Ready to dive in ? Check one of the guides:
- [Installation guide](./docs/install_guide.md)
- [Getting started](./docs/getting_started.md)

Or check the <u>[list of supported services and tools](./docs/modules_list.md)</u>.

> [!CAUTION]
> This module is in heavy developement, and subject to change. This doc is for v2.0, future updates could break your current configuration, so please be sure to read the update docs when it releases !

## Contribute ?
We don't have proper contributing documentation yet, but contributions are always welcome !

We are looking for more modules to add. If you are using one on your own config, why not add it here ?

If you're already a Nix developer, just have a look on how other modules are built and do the same for your module :smile:

Keypoints (for webservices):
- Please use the same common options as other webservices
- Please run the service in a docker container.
