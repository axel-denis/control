# Easy NixOS homeserver
Despite being one of the best linux distribution choice to setup a server, NixOS can be tough for beginners, which makes it rarely used in practice.

**This repo aims to fix this !**

This package does all the heavy lifting for you, and let you with a "can't be simpler" configuration. See yourself:

```nix
{ homeserver, ...}

{
  homeserver = {
    jellyfin.enable = true; # self hosted google photos !
    immich.enable = true; # self hosted netflix !
    psitransfer.enable = true; # self hosted wetransfer !
    # ...
  };
}
```

**That's all you need to have a server





```nix
# configure your domain (if hosting to the world wide web!)
routing.enable = true;
routing = {
  domain = "yourdomain.com";
  letsencrypt.enable = true;
  letsencrypt.email = "letsencrypt.email@email.com"
};
```