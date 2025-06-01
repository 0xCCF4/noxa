{
  description = "Noxa management tool for multi host nixos setups";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Secret management; enabled for a host if `noxa.agenixSupport` is set to true
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management with rekeying capabilities; enabled for a host if `noxa.agenixRekeySupport` is set to true
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk setup tool, used by the example configuration in `examples/`
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , disko
    , ...
    }@inputs:
      with nixpkgs.lib; with builtins;
      {
        # Nixos modules
        nixosModules.noxa.default = import ./modules inputs;

        # Libraries
        lib = import ./lib inputs;

        # Source code formatter
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

        # Example nixos configuration
        nixosConfigurations = ((import ./examples/flake.nix).outputs (inputs // { noxa = self; })).nixosConfigurations;
      }
      // flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          scopedInputs = inputs // {
            inherit pkgs system;
          };
        in
        {

          # Packages
          packages.doc = pkgs.callPackage ./pkgs/doc.nix scopedInputs;

          # Dev shells
          devShells = import ./shells scopedInputs;
        }
      );
}
