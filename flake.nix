{
  description = "Home Server Service Modules (aggregated)";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; };

  outputs = { self, ... }:
    let
      system = "x86_64-linux";
      lib = self.inputs.nixpkgs.lib;
      helpers = import ./lib;
    in {
      nixosModules.default = { ... }@args:
        let inherit (args) config;
        in {
          imports = [
            # ./modules/jellyfin/jellyfin.nix
            ./modules/immich/immich.nix
            # ./modules/transmission/transmission.nix
          ];
        };
    };
}
