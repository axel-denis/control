# Defaults

To keep configurations files simple, a lot of settings are optionnal. Unless expressly specified, they fallback to nicely set default values.

## Enable
Needless to say, all modules and tools are disabled by default. To enable something, you must always set `<module>.enable = true;`.

## Paths


**If not set, every path is created under the *main path* `/control_appdata/`**

All services requiring one (or many) folders to store data are assigned to the default path:
```
/<main path>/<service name>/<...>
```

Example for [Jellyfin](./perModule/jellyfin.md):
```
/
└── control_appdata
    └── jellyfin
        ├── # specific folders required by the app:
        ├── config
        └── media
```

> [!TIP]
> You can change the **main path** with the variable `defaultPath`
> ```nix
> control {
>     defaultPath = "/somewhere/else";
>     # ... other modules ...
> };
> ```
> Useful to change your main disk without having to set every app path by hand.

## Ports
If not specified, those ports will be used as default for each app.
You can check the [routing](./perModule/routing.md) module for more info.

| Service      | Default port |
| ------------ | ------------ |
| Immich       | 10001        |
| Jellyfin     | 10002        |
| Transmission | 10003        |
| Chibisafe    | 10004        |
| Psitransfer  | 10005        |
| Speedtest    | 10006        |
