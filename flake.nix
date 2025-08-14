{
  description = "Home Server Service Modules (aggregated)";

  outputs = { self, ... }:
    let
      system = "x86_64-linux";
      lib = import ./lib;
    in {
      nixosModules.default = { lib, ... }@args:
        let inherit (args) config lib;
        in {
          imports = [
            ./modules/jellyfin/jellyfin.nix
            ./modules/immich/immich.nix
            ./modules/transmission/transmission.nix
          ];
        };
    };
}
