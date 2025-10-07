# Pi-hole

### Info
> "Network-wide Ad Blocking"

> [!IMPORTANT]
> Pi-hole is a custom DNS server that block defined domain lists (generally ad or tracking servers).
> For it to work, you need to enable it and configure it here (*control;'s* config), but __also configure your router/device to use it as a DNS (*not* this config)__
>
> See [Pi-hole's "Post-Install" docs](https://docs.pi-hole.net/main/post-install/)
>
> As of now, Pi-hole can't be used by the [routing](./routing.md) module (can't expose a domain). If you think that could be useful, please open an issue.

### Options

`pihole.dbPasswordFile`:
A file containing a password for the internal database of Immich. (Required)

`pihole.paths`:

| Name                   | Description                            | Default                                  |
|------------------------|----------------------------------------|------------------------------------------|
| port                   | Port for the web interface             | `10007`                                  |
| `pihole.paths.default` | Path for the app's data                | `<main path>/pihole`                     |
| timezone               | Timezone                               | `config.time.timeZone` of your system    |
| password               | First account password                 | $\color{red} *$                          |
| machineLearning        | Path for Immich machine learning cache | `<main path>/<default>/machine_learning` |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).

