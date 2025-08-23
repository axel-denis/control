{
  description = "Home Server Service Modules (aggregated)";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      helpers = import ./helpers { inherit lib; };

      mkModule = path:
        { ... }@args:
        import path (args // { inherit helpers lib; });
    in {
      nixosModules = {
        immich = mkModule ./modules/immich.nix;
        jellyfin = mkModule ./modules/jellyfin.nix;
        transmission = mkModule ./modules/transmission.nix;
        openspeedtest = mkModule ./modules/openspeedtest.nix;

        default = { ... }: {
          imports = [
            self.nixosModules.immich
            self.nixosModules.jellyfin
            self.nixosModules.transmission
            self.nixosModules.openspeedtest
          ];
        };
      };
    };
}
