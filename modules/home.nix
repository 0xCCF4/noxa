{ config, lib, ... }: with lib; with lib.types; {
  options.noxa.home =
    let
      cfg = config.noxa.addons;
    in
    {
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
          type = attrsOf set;
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
}
