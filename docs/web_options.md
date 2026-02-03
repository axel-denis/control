# Web services options
All the web services (Immich, Jellyfin, OpenSpeedTest...) shares some common web related options.
They are the same accross the web services.

> [!IMPORTANT]
> All options defined here are optional and can be left unspecified unless you need a specific customization.
> 
> A module is not enabled unless you set the `enable` option to `true` for this module.

## `<service>.enable` $\color{red} *$
Enable the service<br>
Default: `false` (required `true` to enable the module)

## `<service>.version`
The container version to use.<br>
Default: `latest` (or equivalent).

> [!WARNING]
> You should not set it unless you know what you are doing. Use a correct version for this container, and a version compatible with the current Nix configuration for this module.

## `<service>.subdomain`
The subdomain used by the [routing](./perModule/routing.md) module to create subdomains like `subdomain.yourdomain.com`.<br>
Default: the service name (lowercase)

## `<service>.port`
Port to use the service (if routing is disabled)<br>
You can see the default port for each app here: [defaults](./defaults.md)

## `<service>.forceLan`
Keeps LAN access, even if the [routing](./perModule/routing.md) module is enabled.<br>
Useful to keep the speed of the LAN on your home network.<br>
Default: false

## `<service>.lanOnly`
Completly disable the [routing](./perModule/routing.md) module for this service.<br>
Default: false