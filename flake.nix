{
  description = "Home Server Service Modules (aggregated)";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; };

  outputs = { self, ... }:
    let
      system = "x86_64-linux";
      lib = import ./lib { inherit inputs; };
    in {
      nixosModules.default = { ... }@args:
        let inherit (args) config lib;
        in {
          imports = [
            # ./modules/jellyfin/jellyfin.nix
            ./modules/immich/immich.nix
            # ./modules/transmission/transmission.nix
          ];
        };
    };
}
