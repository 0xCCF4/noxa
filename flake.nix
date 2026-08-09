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

    # Flake parts, the module system Noxa itself is built on top of
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Host discovery and defaults for flake-parts, Noxa builds on top of this
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management; import `noxa.nixosModules.secrets` on a host to use it
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management with rekeying capabilities; import `noxa.nixosModules.secrets` on a host to use it
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-parts
    , flake-utils
    , ez-configs
    , nix-net-lib
    , ...
    }@inputs:
    let
      modifiedInputs = inputs // { noxa = self; };
      modules = import ./modules modifiedInputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = flake-utils.lib.defaultSystems;

      imports = [ ./parts ];

      flake = {
        # Nixos modules
        nixosModules = modules.nixos;

        # Noxa's own flake-parts module. Import this into a consumer's
        # `flake-parts.lib.mkFlake` call to declare Noxa-managed hosts:
        #
        #   imports = [ inputs.noxa.flakeModules.default ];
        flakeModules.default = import ./modules/flake-parts {
          noxaFlake = self;
          nixNetLib = nix-net-lib.lib;
          ezConfigsFlakeModule = ez-configs.flakeModule;
        };

        # Libraries
        lib = import ./lib modifiedInputs;

        # Templates
        templates.default = {
          path = ./examples/default;
          description = "Fully featured template. (Recommended)";
        };
        templates.minimal = {
          path = ./examples/minimal;
          description = "Minimal template.";
        };
      };
    };
}
