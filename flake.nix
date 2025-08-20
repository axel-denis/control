{
  description = "Home Server Service Modules (aggregated)";

  outputs = { self, ... }:
    let
      system = "x86_64-linux";
      helpers = import ./lib;
    in {
      nixosModules.default = { ... }@args:
        let inherit (args) config helpers;
        in {
          imports = [
            # ./modules/jellyfin/jellyfin.nix
            ./modules/immich/immich.nix
            # ./modules/transmission/transmission.nix
          ];
        };
    };
}
