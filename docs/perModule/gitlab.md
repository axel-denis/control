# GitLab

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`gitlab.ssh-port`:
SSH port for GitLab

> [!IMPORTANT]
> SSH port for GitLab is not part of the [routing](./routing.md) module and has to be managed by your means

`gitlab.paths`:
| Name    | Description              | Default                         |
| ------- | ------------------------ | ------------------------------- |
| default | The main path of the app | `<main path>/gitlab`            |
| config  | Path for GitLab config   | `<main path>/<default>/config`  |
| logs    | Path for GitLab logs     | `<main path>/<default>/logs`    |
| data    | Path for GitLab data     | `<main path>/<default>/uploads` |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `gitlab.paths.default`
