# Installation guide
You need to add this flake into your main flakes inputs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # (example)
  # ...
  control.url = "github:axel-denis/control/v2.0";
  control.inputs.nixpkgs.follows = "nixpkgs";
};
```

Then in the `modules` part, add the main module:
```nix
modules = [
  control.nixosModules.default
  # ... other modules, like ./configuration.nix
];
```

---

Here is an example of a complete flake:
```nix
{
  description = "My server NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    control.url = "github:axel-denis/control/v2.0"; # don't forget to point a specific version
  };

  outputs = inputs@{ self, nixpkgs, control, ... }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        control.nixosModules.default
      ];
    };
  };
}
```

---

Then, in any configuration file, you can proceed as follow:

```nix
{ control, pkgs, ...}:
{
  control = {
    jellyfin.enable = true;
    immich.enable = true;
    # ...
  };
}
```

### Next: [Getting started](./getting_started.md)