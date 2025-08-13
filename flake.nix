{
  description = "Home Server Service Modules";

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosModules = {
      default = self.nixosModule;
      transmission = ./modules/transmission.nix;
      immich = ./modules/immich.nix;
      jellyfin = ./modules/jellyfin.nix;
    };
#    lib = import ./lib { inherit (pkgs) lib; };
  };
}
