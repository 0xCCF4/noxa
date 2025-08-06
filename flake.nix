{
  description = "Noxa management tool for multi host nixos setups";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # IP data types and utility functions
    nix-net-lib = {
      url = "github:0xCCF4/nix-net-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      let
        modifiedInputs = (inputs // { noxa = self; });
        modules = import ./modules modifiedInputs;
        prefixAttrs = prefix: attrs: attrsets.mapAttrs' (name: value: nameValuePair "${prefix}${name}" value) attrs;
        noxaConfiguration = ((import ./examples/flake.nix).outputs modifiedInputs).noxaConfiguration;
      in
      {
        # Nixos modules
        nixosModules = modules.nixos;

        # Noxa modules
        noxaModules = modules.noxa;

        # Libraries
        lib = import ./lib modifiedInputs;

        # Source code formatter
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

        # Example nixos configuration
        nixosConfigurations =
          { }#(prefixAttrs "plain:" ((import ./examples/plain-no-noxa-modules/flake.nix).outputs (inputs // { noxa = self; })).nixosConfigurations)
        ; #// (prefixAttrs "noxa:" ((import ./examples/noxa-modules/flake.nix).outputs (inputs // { noxa = self; })).nixosConfigurations);

        # Configuration of agenix rekey for usage in the examples
        agenix-rekey = inputs.agenix-rekey.configure {
          userFlake = self;
          nixosConfigurations = attrsets.mapAttrs (name: value: { config = value.configuration; }) noxaConfiguration.config.nodes;
        };

        # Expose example configuration
        inherit noxaConfiguration;

        # Templates
        templates.default = {
          path = ./examples;
          description = "Basic noxa configuration example";
        };
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
          packages.prebuilt = pkgs.callPackage ./pkgs/prebuilt.nix scopedInputs;

          # Dev shells
          devShells = import ./shells scopedInputs;
        }
      );
}
