{
  description = "Home Server Service Modules (aggregated)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      helpers = import ./helpers { inherit lib pkgs; };

      pkgs = import nixpkgs { inherit system; };

      mkModule = path: { ... }@args: import path (args // { inherit helpers lib pkgs; });
    in
    {
      nixosModules = {
        base = mkModule ./modules/base.nix;
        #perms = mkModule ./modules/perms.nix;
        immich = mkModule ./modules/immich.nix;
        jellyfin = mkModule ./modules/jellyfin.nix;
        transmission = mkModule ./modules/transmission.nix;
        openspeedtest = mkModule ./modules/openspeedtest.nix;
        terminal = mkModule ./modules/terminal.nix;
        chibisafe = mkModule ./modules/chibisafe.nix;
        hdd-spindown = mkModule ./modules/hdd-spindown.nix;
        psitransfer = mkModule ./modules/psitransfer.nix;
        routing = mkModule ./modules/routing.nix;
        pihole = mkModule ./modules/pihole.nix;
        siyuan = mkModule ./modules/siyuan.nix;
        cloudreve = mkModule ./modules/cloudreve.nix;
        custom-routing = mkModule ./modules/custom-routing.nix;
        gitlab = mkModule ./modules/gitlab.nix;
        gitea = mkModule ./modules/gitea.nix;

        default =
          { lib, ... }:
          {
            imports = [
              self.nixosModules.base
              self.nixosModules.immich
              self.nixosModules.jellyfin
              self.nixosModules.transmission
              self.nixosModules.openspeedtest
              self.nixosModules.terminal
              self.nixosModules.chibisafe
              self.nixosModules.hdd-spindown
              self.nixosModules.psitransfer
              self.nixosModules.routing
              self.nixosModules.pihole
              self.nixosModules.siyuan
              self.nixosModules.cloudreve
              self.nixosModules.custom-routing
              self.nixosModules.gitlab
              self.nixosModules.gitea
            ];
          };
      };
    };
}
