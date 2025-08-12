{
  description = "Home Server Service Modules";

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    modules = [
      ./modules/transmission.nix
      ./modules/immich.nix
      ./modules/jellyfin.nix
    ];
    lib = import ./lib { inherit (pkgs) lib; };
  };
}
