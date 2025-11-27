# Cloudreve

### Info
> "Smooth File Upload and Management Experience"

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`cloudreve.dbIsHdd`:
Enable if your database is stored on an HDD drive (postgres optimizations)

`cloudreve.paths`:
| Name     | Description                        | Default                          |
| -------- | ---------------------------------- | -------------------------------- |
| default  | The main path of the app           | `<main path>/cloudreve`          |
| database | Path for Cloudreve database        | `<main path>/<default>/database` |
| redis    | Path for Cloudreve redis (cache)   | `<main path>/<default>/redis` |
| uploads  | Path for Cloudreve uploads (files) | `<main path>/<default>/uploads`  |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `cloudreve.paths.default`
