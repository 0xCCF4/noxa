{
  self,
  nixpkgs,
  lib ? nixpkgs.lib,
  noxa-lib ? self.lib.noxa-lib,
  system ? "x86_64-linux", # use this for stage 1 configuration
  ...
}:
with lib; with lib.filesystem; with lib.attrsets; with builtins;
let
  nixos-instantiate =
    {
      hostLocations ? throw "list of paths to host configurations is required",
      additionalArgs ? { },
    }:
    let
      nixosModulesWithDuplicates = map (
        path:
        let
          mainConfigurationPlatform = system: lib.nixosSystem (
            additionalArgs //
              {
                system = additionalArgs.system or system;
                modules = [ path ] ++ (additionalArgs.modules or []);
              }
          );

          # Evaluate the target system by using the system set in caller arguments
          stageOneConfig = mainConfigurationPlatform system;
          stageOneTargetPlatform = stageOneConfig.config.nixpkgs.system;
          stageTwoConfig = mainConfigurationPlatform stageOneTargetPlatform;
          stageTwoTargetPlatform = stageTwoConfig.config.nixpkgs.system;

        # If target platform is different then re-evaluate the configuration
          mainConfiguration = if stageOneTargetPlatform == system then
            stageOneConfig
          else if stageTwoTargetPlatform != stageOneTargetPlatform then
            throw "There is some shenanigans happening with conditional setting of nixpkgs.system. Stop this! Target platform mismatch: ${stageTwoTargetPlatform} <- ${stageOneTargetPlatform} (system = ${system})."
          else
            stageTwoConfig;
        in
        {
          "${mainConfiguration.config.networking.hostName}" = {
            configuration = mainConfiguration;
            location = path;
          };
        }
      ) hostLocations;

      # Guard rails against duplicates host names
      groupedByHostname = groupBy (
        x: (head (attrValues x)).configuration.config.networking.hostName
      ) nixosModulesWithDuplicates;
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
          (foldl (a: b: a//b) {} (map (host: mapAttrs (hostname: data: data.configuration) host) nixosModulesWithDuplicates));
    in
    nixosConfigurations;
in
{
  /**
      Instantiates a list of NixOS configurations from the provided set of arguments.

      # Inputs
      - `x` : A path to a host file.
      - `x` : A path to a directory containing multiple host files.
      - `x` : A set of settings of the following form:
        ```nix
        {
          hostLocations = [ <path> ] / <path>; # Location(s) to the host configurations files
          additionalArgs = { <key> = <value>; ... }; # Appended to the lib.nixosSystem call
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
    if typeOf x == "path" then
      (
        if pathIsRegularFile x then
          nixos-instantiate {
            hostLocations = [ x ];
          }
        else if pathIsDirectory x then
          nixos-instantiate {
            hostLocations = noxa-lib.list-nix-directory x;
          }
        else
          throw "nixos-instantiate expects a path to a host file or a directory containing host files"
      )
    else if typeOf x == "set" then
        let
            hostLocations = if typeOf (x.hostLocations or []) == "list" then
                x.hostLocations or []
            else if typeOf (x.hostLocations or []) == "path" then
                noxa-lib.list-nix-directory x.hostLocations
            else
                throw "nixos-instantiate expects a list of paths to host configurations or a path to a directory containing host files";
        in
      nixos-instantiate (x // {inherit hostLocations; })
    else
      throw "nixos-instantiate expects a path to a host file or a settings set"
  );
}
