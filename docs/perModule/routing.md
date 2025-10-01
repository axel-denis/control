# Routing
##### Publish your serveur to the web !

This module will manage your network (ports, domain...)

## Who is it for
Use this module if you wishes to open your server to the web (access it via anywhere, with your domain name).

> [!TIP]
> This module is one of the more complex provided by this flake, as youre network configuration can't be guessed and totally automatized.<br>
> If you only access your server from your local home network, you can leave this disabled.

> [!IMPORTANT]
> We assume you already know basics about the subject (what is a domain name, a DNS, TLS/SSL...)

**Your local network (behind your router) will be referred to as LAN, and the world wide web ad WAN.**


## 1. Basics
In this first part, we will see how to edit default ports, then bind your webservices to your domain, to be able to use them using `appname.yourdomain.com`.

If you followed the [Getting Started](../getting_started.md) guide, you should be left with a config similar to this one. Please edit it like this to focus more on this guide's subject:
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    psitransfer.enable = true;
    openspeedtest.enable = true;
  }
}
```

Right now, you can access services on your local network, by using `<server_ip>:<port>`. By example if your server's ip is `192.168.0.50`, you can access [openspeedtest](./openspeedtest.md) through `192.168.0.50:10006`. Default ports are defined in [the section "port" of the webservices docs](../web_options.md#serviceport).

If you want to set a custom port for an app, that's possible:
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    psitransfer.enable = true;
    openspeedtest = {
        enable = true;
        port = 8080;
    };
  }
}
```

Let's now enable the router to bind everything to it's respective subdomain (don't rebuild it yet, you could get an error):
```nix
{ homeserver, ...}
{
  homeserver = {
    immich.enable = true;
    jellyfin.enable = true;
    psitransfer.enable = true;
    openspeedtest.enable = true;

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

- `domain` is self explanatory. All enabled apps will be binded to **appname.yourdomain.com.**

- `letsencrypt` enables https, getting certificates from [Let's Encrypt](https://letsencrypt.org/). Those certificates will be automatically managed (ACME). The email is an email where you could be contacted for informations relative to your certificate (never received one, but it's there).
  
  Will only work if your dns is already configured and ports 80 & 443 opened (we'll get to that bellow).

> [!IMPORTANT]
> It's really recommanded for your server to use https, and Let's Encrypt ACME provides a nice, free and NixOS compliant way to do it. [Let's Encrypt ToS](https://letsencrypt.org/repository/) has to be accepted.<br>
> This flake does not provide a way to import custom certificates (if you already have some) for now. But that's should be some easy modifications if you want to contribute :smile:

> [!NOTE] 
> With router enabled, all usual containers ports are closed (you can't access by `<your_ip>:<port>` anymore). **Only ports 80 (http) and 443 (https) are opened.**

To access your apps through your domain, you must do those steps:
1. Use your DNS provider to redirect your domain and each subdomain to your router ip.
2. Open your router port's 80 and 443$\color{red} *$ -> *must be open at rebuild-time for the `letsencrypt` option to work.*
3. Rebuild (`sudo nixos-rebuild switch`)

> [!CAUTION]
> $\color{red} *$Important security note here. This guide assume you know the basics about opening a server to the web. If you don't, and are just following the steps of this guide, **please read more on the subject before opening anything.**

**Congrats!** Once you've done that, you can access your apps. In this case,
- [immich.yourdomain.com](https://youtu.be/dQw4w9WgXcQ?si=HqmVdYb3yXppQw41)
- [jellyfin.yourdomain.com](https://youtu.be/dQw4w9WgXcQ?si=HqmVdYb3yXppQw41)
- [psitransfer.yourdomain.com](https://youtu.be/dQw4w9WgXcQ?si=HqmVdYb3yXppQw41)
- [openspeedtest.yourdomain.com](https://youtu.be/dQw4w9WgXcQ?si=HqmVdYb3yXppQw41)

## 2. Customization
Now that we have a basic configuration of the routing module, let's see some customization:

### Subodmain customization

<details>
<summary>See more</summary>

```nix
{ homeserver, ...}
{
  homeserver = {
    immich = {
        enable = true;
        subdomain = "photos";
        port = 8081;
    };

    jellyfin.enable = true;
    psitransfer.enable = true;

    openspeedtest.enable = true;

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

- `<module>.subdomain` -> changes the subdomain for this app.
- `<module>.port` -> Will use the specified port in the background, but keep in mind that, with this config, it's not directly accessible while the routing module is enabled.

</details>

### Force LAN access

<details>
<summary>See more</summary>

```nix
{ homeserver, ...}
{
  homeserver = {
    immich = {
        enable = true;
        subdomain = "photos";
        port = 8081;
        forceLan = true; # <-
    };

    jellyfin.enable = true;
    psitransfer.enable = true;

    openspeedtest.enable = true;

    routing = {
      enable = true;
      domain = "yourdomain.com";
      letsencrypt = {
        enable = true;
        email = "email.for.letsencrypt@example.com";
      };
      test = true; # <-
    };
  }
}
```

- `<module>.subdomain` -> changes the subdomain for this app.
- `<module>.port` -> Will use the specified port in the background, but keep in mind that, with this config, it's not directly accessible while the routing module is enabled.
</details>

<br>
<br>
<br>

---

useful to create mandatory option :
## `<service>.enable` $\color{red} *$