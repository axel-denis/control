# Chibisafe
###### The Free Software Media System.

### Info
> "Self-hosted photo and video management solution"

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`chibisafe.paths`:
| Name     | Description                                | Default                        |
| -------- | ------------------------------------------ | ------------------------------ |
| default  | The main path of the app                   | `<main path>/chibisafe`        |
| database | Path for Chibisafe database                | `<main path>/<default>/media`  |
| uploads  | Path for Chibisafe uploads (photos/videos) | `<main path>/<default>/config` |
| logs     | Path for Chibisafe logs                    | `<main path>/<default>/config` |

- `<main path>` - Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `chibisafe.paths.default`
