{ self
, nixpkgs
, lib ? nixpkgs.lib
, noxa ? self
, system ? "x86_64-linux"
, # use this for stage 1 configuration

  # Noxa addons
  home-manager
, agenix
, agenix-rekey
, ...
}:
with lib; with lib.filesystem; with lib.attrsets; with builtins;
let
  nixos-instantiate =
    { hostLocations ? throw "list of paths to host configurations is required"
    , additionalArgs ? { }
    , nixosConfigurations ? throw "nixosConfigurations is required, please supply a list of all nixos hosts managed through Noxa. Either supply [ NixosConfiguration ] or { NixosConfiguration } using self.nixosConfigurations"
    ,
    }:
    let
      nixosModulesWithDuplicates = map
        (
          module:
          let
            # Inject the modules for Noxa addons to specialArgs if not already present
            inputWithDefaults = specialArgs:
              (specialArgs // {
                nixpkgs = specialArgs.inputs or nixpkgs;
                home-manager = specialArgs.inputs.home-manager or home-manager;
                agenix = specialArgs.inputs.agenix or agenix;
                agenix-rekey = specialArgs.inputs.agenix-rekey or agenix-rekey;
              });

            # Wrapped invocation of lib.nixosSystem
            mainConfigurationPlatform =
              { system
              , additionalModules ? [ ]
              , stageOneConfig ? { config = { }; }
              ,
              }: lib.nixosSystem (
                additionalArgs //
                {
                  system = additionalArgs.system or system;
                  modules = [ module self.nixosModules.noxa.default ] ++ additionalModules;
                  specialArgs = (inputWithDefaults (additionalArgs.specialArgs or { })) // {
                    noxa = ((additionalArgs.specialArgs or { }).noxa or (self // { nixosConfigurations = { }; })) // {
                      # remove nixosConfigurations, since it contains just the example configuration -> prevent circular dependency
                      # augment noxa special args with stageOneConfig and all nixosConfigurations
                      inherit stageOneConfig;
                      inherit nixosConfigurations;
                    };
                  };
                }
              );

            # Evaluate the target system for the `config.nixpkgs.system` option by predicting that the target platform is x86_64-linux.
            stageOneConfig = mainConfigurationPlatform {
              inherit system;
              additionalModules = additionalArgs.modules or [ ];
            };
            stageOneTargetPlatform = stageOneConfig.config.nixpkgs.system;

            # Use the actual target platform setting to build the final configuration.
            stageTwoConfig = mainConfigurationPlatform {
              system = stageOneTargetPlatform;
              additionalModules = additionalArgs.modules or [ ];
              inherit stageOneConfig;
            };
            stageTwoTargetPlatform = stageTwoConfig.config.nixpkgs.system;

            # Apply configuration overlays
            noxaOverlays = stageOneConfig.config.noxa.overlays or [ ];
            overlayedStageTwoConfig =
              foldl
                (
                  acc: overlay:
                    overlay {
                      final = overlayedStageTwoConfig;
                      prev = acc;
                      stageOne = stageOneConfig;
                    }
                )
                stageTwoConfig
                noxaOverlays;

            # If target platform is different then re-evaluate the configuration, then something weird is going on.
            mainConfiguration =
              if stageOneTargetPlatform == system then
                stageOneConfig
              else if stageTwoTargetPlatform != stageOneTargetPlatform then
                throw "There is some shenanigans happening with conditional setting of `nixpkgs.system`. Stop this! Target platform mismatch: ${stageTwoTargetPlatform} <- ${stageOneTargetPlatform} (system = ${system})."
              else
                overlayedStageTwoConfig;
          in
          {
            "${mainConfiguration.config.networking.hostName}" = {
              configuration = mainConfiguration;
              location = path;
            };
          }
        )
        hostLocations;

      # Guard rails against duplicates host names
      groupedByHostname = groupBy
        (
          x: (head (attrValues x)).configuration.config.networking.hostName
        )
        nixosModulesWithDuplicates;
      duplicates = filterAttrs (name: val: length val > 1) (groupedByHostname);
      firstDuplicate =
        if length (attrValues duplicates) == 0 then
          throw "No duplicates found"
        else
          head (attrValues duplicates);

      nixosConfigurations =
        if length (attrValues duplicates) > 0 then
          throw "Duplicate host names found: ${
            concatStringsSep ", " (map (x: x.location) firstDuplicate)
          }. These configuration files use the same host name: ${
            firstDuplicate [ 0 ].configuration.config.networking.hostName
          }. Please resolve the duplicates."
        else
          (foldl (a: b: a // b) { } (map (host: mapAttrs (hostname: data: data.configuration) host) nixosModulesWithDuplicates));
    in
    nixosConfigurations;
in
{
  /**
      Instantiates a list of NixOS configurations from the provided set of arguments.

      # Inputs
      A set of settings of the following form:
        ```nix
        {
          hostLocations = [ <path> ] / <path>; # Location(s) to the host configurations files
          additionalArgs = { <key> = <value>; ... }; # Appended to the lib.nixosSystem call
          nixosConfigurations = { <name> = <nixosConfiguration>; ... }; or [ <nixosConfiguration> ];
        }
        ```

      # Output
      A set of nixos configurations.
      ```nix
      {
        "<hostname>" = {
          configuration = <nixosConfiguration>;
          location = <path>;
        };
        ...
      }
      ```

      # Type
      ```nix
      Path | Set -> { nixosConfiguration }
      ```
  */
  nixos-instantiate = (
    x:
    if typeOf x == "set" then
      let
        hostLocations =
          if typeOf (x.hostLocations or [ ]) == "list" then
            x.hostLocations or [ ]
          else if typeOf (x.hostLocations or [ ]) == "path" then
            noxa.lib.nixDirectoryToList x.hostLocations
          else
            throw "nixos-instantiate expects a list of paths to host configurations or a path to a directory containing host files";
      in
      nixos-instantiate (x // { inherit hostLocations; })
    else
      throw "nixos-instantiate expects a path to a host file or a settings set"
  );
}
