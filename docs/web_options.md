# Web services options
All the web services (Immich, Jellyfin, OpenSpeedTest...) shares some common web related options.
They are the same accross the web services.

`<service>.<option>`
| Option name | Description                                                                                   |
| ----------- | --------------------------------------------------------------------------------------------- |
| enable      | Enable the service                                                                            |
| version[^1] | Container version                                                                             |
| subdomain   | App subdomain. Used by the router to route to `<subdomain>.yourdomain.com`                    |
| port        | Expose a port (if not using the router. See more on the [router](./perModule/router.md) page) |
| ----------- | -----------------                                                                             |
| ----------- | -----------------                                                                             |
| ----------- | -----------------                                                                             |

[^1]: Used to point a specific version of the container image used. You should not set it unless you know what you are doing.

- `<service>.enable`
> Enable the service.<br>
> `false` by default

- version
> The container version to use.
> `latest` (or equivalent) by default
> > [!WARNING]
> > You should not set it unless you know what you are doing

- version

  The container version to use.
  `latest` (or equivalent) by default
  > [!WARNING]
  > You should not set it unless you know what you are doing