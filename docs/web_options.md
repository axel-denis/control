# Web services options
All the web services (Immich, Jellyfin, OpenSpeedTest...) shares some common web related options.
They are the same accross the web services.

> [!IMPORTANT]
> All options defined here are optional and can be left unspecified unless you need a specific customization.
> 
> A module is not enabled unless you set the `enable` option to `true` for this module.

## `<service>.enable` $\color{red} *$
Enable the service<br>
Default: `false`

## `<service>.version`
The container version to use.<br>
Default: `latest` (or equivalent).

> [!WARNING]
> You should not set it unless you know what you are doing

## `<service>.subdomain`
The subdomain used by the [routing](./perModule/routing.md) module to create subdomains like `subdomain.yourdomain.com`.<br>
Default: the service name (lowercase)

## `<service>.port`
Port to use the service (if routing is disabled)<br>
Default:
| Service      | Default port |
| ------------ | ------------ |
| Immich       | 10001        |
| Jellyfin     | 10002        |
| Transmission | 10003        |
| Chibisafe    | 10004        |
| Psitransfer  | 10005        |
| Speedtest    | 10006        |