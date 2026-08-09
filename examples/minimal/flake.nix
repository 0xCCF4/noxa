{
  description = "Noxa multi-host example flake";

  #########################################################
  #
  # Todos when using this template:
  # 1. Remove the secrets/master.key file from your repository.
  #       git rm secrets/master.key ; rm secrets/master.key
  # 2. Update the master key, see secrets/default.nix
  # 3. Delete `hosts/*` files that you do not need.
  # 4. Delete `hardware/*`files that you don not need.
  # 5. Your are ready to go!
  #
  #########################################################

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake parts, build flake outputs modularly
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Noxa
    noxa = {
      url = "github:0xCCF4/noxa";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.agenix-rekey.follows = "agenix-rekey";
      inputs.home-manager.follows = "home-manager";
    };

    # Secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, noxa, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        noxa.flakeModules.default
        ./config.nix
      ];
    };
}
