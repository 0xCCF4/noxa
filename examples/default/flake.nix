{
  description = "Noxa NixOS template flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware specific configuration templates
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Flake parts, build flake outputs modularly
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Secret management, per host secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management, per host secrets
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cross-host harness and modules on top of ez-configs
    noxa = {
      url = "github:0xccf4/noxa";
      # url = "/home/mx/Documents/noxa";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.agenix.follows = "agenix";
      inputs.agenix-rekey.follows = "agenix-rekey";
    };
  };

  outputs = inputs@{ flake-parts, noxa, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
      imports = [
        noxa.flakeModules.default
        ./parts
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    });
}
