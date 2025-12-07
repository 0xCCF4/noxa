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

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , agenix
    , agenix-rekey
    , noxa
    , home-manager
    , ...
    }:
      with nixpkgs.lib; with builtins;
      {
        # Noxa configuration
        noxaConfiguration = noxa.lib.noxa-instantiate {
          modules = [ ./config.nix ];
          specialArgs = {
            inherit agenix;
            inherit agenix-rekey;
            inherit home-manager;
          };
        };

        # Allow interoperability with "standard" nixos build tools
        nixosConfigurations = attrsets.mapAttrs
          (name: value: {
            config = value.configuration;
            options = value.options;
          })
          (filterAttrs
            (node: value: elem node self.noxaConfiguration.nodeNames)
            self.noxaConfiguration.config.nodes);

        # Agenix rekey module configuration
        # See the wiki <https://0xccf4.github.io/noxa/modules/secrets.html> for more information
        agenix-rekey = agenix-rekey.configure {
          userFlake = self;
          nixosConfigurations = self.nixosConfigurations;
        };
      };
}
