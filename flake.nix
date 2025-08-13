{
  description = "Home Server Service Modules (aggregated)";

  outputs = { self, ... }:
  let
    system = "x86_64-linux";
    #pkgs = import nixpkgs { inherit system; };
    flakeLib = import ./lib; # { inherit (pkgs) lib; }; # your helpers
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

        # If you need to pass your flake helpers into the submodules,
        # have those submodules use `flakeLib` via import arguments (see below).
      };
  };
}
