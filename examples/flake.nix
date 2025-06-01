{
  description = "Noxa multi-host example flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Disk setup tool, used in this example but not required for Noxa
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noxa
    noxa = {
      url = "github:0xCCF4/noxa";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , disko
    , noxa
    , ...
    }@inputs:
      with nixpkgs.lib; with builtins;
      {
        # Nixos configuration
        nixosConfigurations = noxa.lib.nixos-instantiate {
          hostLocations = ./hosts;
          additionalArgs = {
            modules = [ disko.nixosModules.disko ];
          };
        };
      };
}
