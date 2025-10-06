{
  description = "Home Server Service Modules (aggregated)";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      helpers = import ./helpers { inherit lib; };

      pkgs = import nixpkgs { inherit system; };

      mkModule = path:
        { ... }@args:
        import path (args // { inherit helpers lib pkgs; });
    in {
      nixosModules = {
        immich = mkModule ./modules/immich.nix;
        jellyfin = mkModule ./modules/jellyfin.nix;
        transmission = mkModule ./modules/transmission.nix;
        openspeedtest = mkModule ./modules/openspeedtest.nix;
        terminal = mkModule ./modules/terminal.nix;
        chibisafe = mkModule ./modules/chibisafe.nix;
        hdd-spindown = mkModule ./modules/hdd-spindown.nix;
        psitransfer = mkModule ./modules/psitransfer.nix;
        routing = mkModule ./modules/routing.nix;
        wakeonlan = mkModule ./modules/wakeonlan.nix;

        default = { lib, ... }: {
          imports = [
            self.nixosModules.immich
            self.nixosModules.jellyfin
            self.nixosModules.transmission
            self.nixosModules.openspeedtest
            self.nixosModules.terminal
            self.nixosModules.chibisafe
            self.nixosModules.hdd-spindown
            self.nixosModules.psitransfer
            self.nixosModules.routing
            self.nixosModules.wakeonlan
          ];

          options.homeserver = {
            defaultPath = lib.mkOption {
              type = lib.types.str;
              default = "/control_appdata";
              defaultText = "/control_appdata";
              description = "Subdomain to use for Jellyfin";
            };
          };
        };
      };
    };
}
