# Gitea

### Options

#### 1. Firstly check the [common web services options](../web_options.md)
#### 2. Specific options for this module:

`gitea.ssh-port`:
SSH port for Gitea

> [!IMPORTANT]
> SSH port for Gitea is not part of the [routing](./routing.md) module and has to be managed by your means

`gitea.paths`:
| Name    | Description              | Default                         |
| ------- | ------------------------ | ------------------------------- |
| default | The main path of the app | `<main path>/gitea`            |

- `<main path>` = Main path for all the apps. See [defaults](../defaults.md#paths).
- `<default>` - `gitea.paths.default`
