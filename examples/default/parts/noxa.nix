{ inputs, lib, self, ... }: with lib; let
  hosts = inputs.noxa.lib.nixDirectoryToAttr' ./../hosts;
in
{
  flake = {
    # Agenix rekey module configuration
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = mapAttrs
        (name: value: {
          config = value.configuration;
        })
        (filterAttrs (name: value: name != "iso") self.noxaConfiguration.config.nodes);
    };

    # NixOS tool compatibility
    nixosConfigurations = mapAttrs
      (name: value: {
        config = value.configuration;
        options = value.options;
      })
      self.noxaConfiguration.config.nodes;

    # Define all hosts
    noxaConfiguration = inputs.noxa.lib.noxa-instantiate {
      specialArgs = { };
      modules = [
        ({ lib, specialArgs, ... }: {
          # overlay own packages
          defaults.configuration.imports = [
            self.nixosModules.default
            inputs.home-manager.nixosModules.default
          ];
          defaults.specialArgs = {
            # All these inputs will be available for all hosts, if they import them

            inherit (inputs) nixos-hardware;
            inherit (inputs) agenix;
            inherit (inputs) agenix-rekey;
            inherit (inputs) home-manager;
            inherit (inputs) nixpkgs-stable;
            inherit (inputs.self) users;
            inherit (inputs) self;
          };

          nodes = attrsets.mapAttrs
            (name: path: {
              configuration = {
                imports = [
                  path
                  ({ config, ... }: {
                    nixpkgs.overlays = [ (final: prev: self.packages."${config.nixpkgs.hostPlatform.system}") ];
                  })
                ];

                config.networking.hostName = mkDefault name;
              };
            })
            hosts;

          nodeNames = attrsets.mapAttrsToList (name: path: name) hosts;
        })
        self.noxaModules.default
      ];
    };
  };
}
