{
  description = "Home Server Service Modules (aggregated)";

  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
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
        #transmission = mkModule ./modules/transmission.nix;
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

        default = { lib, ... }: {
          imports = [
            home-manager.nixosModules.home-manager

            self.nixosModules.immich
            self.nixosModules.jellyfin
            #self.nixosModules.transmission
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
          ];

          options.control = {
            defaultPath = lib.mkOption {
              type = lib.types.str;
              default = "/control_appdata";
              defaultText = "/control_appdata";
              description = "Subdomain to use for all Control apps";
            };

            updateContainers = lib.mkEnableOption
              "Pulls the newest image of each enabled container";
            
            isolation = lib.mkEnableOption
              ''
                Each container mountpoints are make through a separate user to prevent
                files from one app from being read through another unauthorized app
              '';
          };

          config = {
            #virtualisation.oci-containers.backend = "docker"; # defaults to podman

            users.users.control = {
              isNormalUser = true;
              uid = 10000;
              group = "control";
            };

            users.groups.control = {
              gid = 10000;
              members = [ "control" ];
            };
          };
        };
      };
    };
}
