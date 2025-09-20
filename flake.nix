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
        terminal = mkModule ./modules/terminal.nix;
        chibisafe = mkModule ./modules/chibisafe.nix;
        hdd-spindown = mkModule ./modules/hdd-spindown.nix;
        psitransfer = mkModule ./modules/psitransfer.nix;
        projectsend = mkModule ./modules/projectsend.nix;

        default = { ... }: {
          imports = [
            self.nixosModules.immich
            self.nixosModules.jellyfin
            self.nixosModules.transmission
            self.nixosModules.terminal
            self.nixosModules.chibisafe
            self.nixosModules.hdd-spindown
            self.nixosModules.psitransfer
            self.nixosModules.projectsend
          ];
        };
      };
    };
}
