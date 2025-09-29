# Wake on Lan
###### Allows your server to be started from anywhere.

> [!TIP]
> Learn about wake on lan on [wikipedia](https://en.wikipedia.org/wiki/Wake-on-LAN).

---

### Options
`wakeonlan.<option>`
| Option  name | Type | Example  | Description                                |
| ------------ | ---- | -------- | ------------------------------------------ |
| enable       | bool | true     | Enable this function                       |
| interface    | str  | "enp3s0" | Interface on which wake on lan will listen |

---

### Example
```nix
# example setup to enable wake on lan on interface enp3s0
wakeonlan {
    enable = true;
    interface = "enp3s0";
};
```
---

> [!IMPORTANT]
> For wake on lan to receive your requests, your router needs to be properly configured to let [magic packets](https://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet) in. This configuration differs from router to router but generally is just an option to enable.

> [!WARNING]
> Some motherboards configure wake on lan from BIOS/UEFI. This makes this setting irrelevant. It's advised to check your motherboard manual or options and configure wake on lan directly on it.
