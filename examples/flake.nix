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
    , agenix
    , agenix-rekey
    , noxa
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
          };
        };
      };
}
