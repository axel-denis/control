# Installation guide
You need to add this flake into your main flakes inputs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # (example)
  # ...
  homeserver.url = "github:axel-denis/nixos-homeserver";
  homeserver.inputs.nixpkgs.follows = "nixpkgs";
};
```

Then in the `modules` part, add the main module:
```nix
modules = [
  homeserver.nixosModules.default
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
    homeserver.url = "github:axel-denis/nixos-homeserver/cecb846e46539d76ab33acbd3d26eafe1a83b4ba"; # hash to point a specific version
    homeserver.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, homeserver, ... }: let
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
        ./other_configuration.nix
        homeserver.nixosModules.default
      ];
    };
  };
}
```