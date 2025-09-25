# Easy NixOS homeserver
Despite being one of the best linux distribution choice to setup a server, NixOS can be tough for beginners, which makes it rarely used in practice.

**This repo aims to fix this !**

This package does all the heavy lifting for you, and let you with a "can't be simpler" configuration. See yourself:

```nix
{ homeserver, ...}

{
  homeserver = {
    jellyfin.enable = true; # self hosted google photos
    immich.enable = true; # self hosted netflix
    psitransfer.enable = true; # self hosted wetransfer
    # ...there's more if you want
  };
}
```

**That's all you need to have a homeserver hosting Jellyfin, Immich and Psitransfer !**

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

> [!TIP] Batteries included
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

> [!NOTE] The same properties can be used for other webservices as well.

---

<br>

*Oh, and we also provide tools like terminal configuration [(oh my zsh)](https://ohmyz.sh/) and hdd-spindown. You'll see that later in the docs* :)

---

<br>

## Ready to dive in ? Check one of the guides:
- [For NixOS beginner]()
- [For NixOS regular user]()

Or check the <u>[list of supported services and tools]()</u>.
