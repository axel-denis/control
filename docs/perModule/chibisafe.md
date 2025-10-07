# Chibisafe

### Info
> "Chibisafe is a beautiful and performant vault to save all your files in the cloud."

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`chibisafe.paths`:
| Name     | Description                                | Default                          |
| -------- | ------------------------------------------ | -------------------------------- |
| default  | The main path of the app                   | `<main path>/chibisafe`          |
| database | Path for Chibisafe database                | `<main path>/<default>/database` |
| uploads  | Path for Chibisafe uploads (photos/videos) | `<main path>/<default>/uploads`  |
| logs     | Path for Chibisafe logs                    | `<main path>/<default>/logs`     |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `chibisafe.paths.default`
