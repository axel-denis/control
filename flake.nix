{
  description = "Home Server Service Modules";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = import ./lib { inherit (pkgs) lib; };
    in {
      nixosModules.default = { lib, ... }@args:
        let inherit (args) config pkgs;
        in import ./modules { inherit lib config pkgs; };
    };
}
