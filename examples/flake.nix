{
  description = "Noxa multi-host example flake";

  #########################################################
  #
  # Todos when using this example as a template:
  # 1. Remove the secrets/master.key file from your repository.
  #       git rm secrets/master.key ; rm secrets/master.key
  # 2. Change the url of the master key to a string value, see file `shared.nix`.
  # 3. Generate a new master key:
  #       nix shell nixpkgs#age
  #       age-keygen -o <your-master-key-file-location>
  # 4. Update the public key part of your master key in `shared.nix`.
  # 5. Delete `hosts/*` files that you do not need.
  # 6. Remove config from `config.nix` that you do not need.
  # 7. Your are ready to go!
  #
  #########################################################

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
      inputs.agenix.follows = "agenix";
      inputs.agenix-rekey.follows = "agenix-rekey";
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

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , disko
    , agenix
    , agenix-rekey
    , noxa
    , home-manager
    , ...
    }:
      with nixpkgs.lib; with builtins;
      {
        # Agenix rekey module configuration
        agenix-rekey = agenix-rekey.configure {
          userFlake = self;
          nixosConfigurations = attrsets.mapAttrs
            (name: value: {
              config = value.configuration;
            })
            self.noxaConfiguration.config.nodes;
        };

        # Noxa configuration
        noxaConfiguration = noxa.lib.noxa-instantiate {
          modules = [ ./config.nix ];
          specialArgs = {
            inherit disko;
            inherit agenix;
            inherit agenix-rekey;
            inherit home-manager;
          };
        };
      };
}
