# Immich

### Info
> "Self-hosted photo and video management solution"

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`immich.dbPasswordFile`:
A file containing a password for the internal database of Immich. (Required)

`immich.paths`:
| Name            | Description                             | Default                                  |
| --------------- | --------------------------------------- | ---------------------------------------- |
| default         | The main path of the app                | `<main path>/immich`                     |
| database        | Path for Immich database                | `<main path>/<default>/database`         |
| uploads         | Path for Immich uploads (photos/videos) | `<main path>/<default>/uploads`          |
| machineLearning | Path for Immich machine learning cache  | `<main path>/<default>/machine_learning` |

- `<main path>` - Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `immich.paths.default`
