{ config, lib, noxa, home-manager, ... }: with lib; with lib.types; let
  cfg = config.noxa.home;

  hmModuleFromInputs = if home-manager != null then home-manager.nixosModules.default else throw "home-manager module is not available, maybe you forgot to include it in your flake inputs?";
in
{
  options.noxa.home = {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Sets the default enable state for all home management options in Noxa.
      '';
    };

    home-manager = {
      enable = mkOption {
        type = bool;
        default = config.noxa.home.enable;
        description = ''
          Enables the shared user configuration feature. For each user on the system, the set
          defined in `noxa.home.sharedUserConfig.users` is searched to check if there is a
          common user configuration for that user.

          If a user is found (by key matching the user's name), the module specified, will be added
          to that user's home-manager configuration.
        '';
      };

      homeManagerModule = mkOption {
        type = anything; # todo change this to a more specific type
        default = hmModuleFromInputs;
        description = ''
          The home-manager module that will be added to the nixos configuration if `noxa.home.home-manager.addHomeManagerModule` is set to true.
        '';
      };

      addHomeManagerModule = mkOption {
        type = bool;
        default = true;
        description = ''
          Adds the home-manager module to nixos configuration. If set to false, the home-manager
          module will not be added to the nixos configuration automatically, and you will
          have to add it manually.
        '';
      };

      users = mkOption {
        type = attrsOf anything; # todo change this to a more specific type
        default = { };
        description = ''
          A set { <username> = <module>; ... } where if the user <username> exists on the system,
          the module <module> will be added to that user's home-manager configuration; given that
          `noxa.home.home-manager.enable` is set to true.
        '';
      };
    };

    direct = {
      enable = mkOption {
        type = bool;
        default = config.noxa.home.enable;
        description = ''
          Enables the direct user configuration feature. For each user on the system, the set
          defined in `noxa.home.direct.users` is searched to check if there is a shared user
          configuration for that user.
        '';
      };

      users = mkOption {
        type = attrsOf anything;
        default = { };
        description = ''
          A set { <username> = <set>; ... } where if the user <username> exists on the system,
          the set <set> will added user's configuration in `users.users.<name>`; given that
          `noxa.home.direct.enable` is set to true.

          Note that one should make of appropriate `lib.mkDefault` or `lib.mkOverride` to avoid
          problems when overriding the shared user configuration per host.
        '';
      };
    };
  };

  imports =
    let
      addHomeManagerModule = attrsets.attrByPath [ "noxa" "home" "home-manager" "addHomeManagerModule" ] false noxa.stageOneConfig.config;
      enableHomeManager = attrsets.attrByPath [ "noxa" "home" "home-manager" "enable" ] false noxa.stageOneConfig.config;
      hmModule = attrsets.attrByPath [ "noxa" "home" "home-manager" "homeManagerModule" ] hmModuleFromInputs noxa.stageOneConfig.config;

      directUserEnabled = attrsets.attrByPath [ "noxa" "home" "direct" "enable" ] false noxa.stageOneConfig.config;
      userDefaultDirectConfiguration = attrsets.mapAttrs (username: d: cfg.direct.users."${username}" or { }) noxa.stageOneConfig.config.users.users;

    in
    [ ]
    ++ lists.optional (addHomeManagerModule && enableHomeManager) hmModule
    ++ lists.optional directUserEnabled {
      config.users.users = userDefaultDirectConfiguration;
    };
}
