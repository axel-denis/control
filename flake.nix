{
  description = "Home Server Service Modules (aggregated)";

  outputs = { self, ... }:
  let
    system = "x86_64-linux";
    flakeLib = import ./lib;
  in {
    nixosModules.default = { lib, ... }@args:
      let
        inherit (args) config pkgs;
      in {
        # This module simply imports the other modules
        imports = [
          ./modules/jellyfin/jellyfin.nix
          ./modules/immich/immich.nix
          ./modules/transmission/transmission.nix
        ];
      };
  };
}
