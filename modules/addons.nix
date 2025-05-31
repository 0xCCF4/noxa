{ config, lib, ... }: with lib; with lib.types; {
  options.noxa.addons =
    let
      cfg = config.noxa.addons;
    in
    {
      externalModuleSupport = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable third-party modules in Noxa defined below. The value set will determine the default enable state of the modules.

          This option must be set in the host's main configuration file, not in any sub-modules. During stage-1 evaluation Noxa
          will set the imports = [...] option to an empty list, and evaluate the host's main module to determine the value of this option.
        '';
      };

      homeManagerSupport = mkOption {
        type = bool;
        default = cfg.externalModuleSupport;
        description = ''
          Enable Home Manager (github:nix-community/home-manager) support in Noxa. The home-manager module will automatically be included to your nixos configuration.

          This will allow you to use Home Manager modules in your Noxa configurations; enabling common user configurations.

          This option must be set in the host's main configuration file, not in any sub-modules. During stage-1 evaluation Noxa
          will set the imports = [...] option to an empty list, and evaluate the host's main module to determine the value of this option.
        '';
      };

      agenixSupport = mkOption {
        type = bool;
        default = cfg.externalModuleSupport;
        description = ''
          Enable Agenix (github:ryantm/agenix) support in Noxa. The agenix module will automatically be included to your nixos configuration.
          This will allow you to use Agenix secrets in your Noxa configurations; enabling secure secret management.

          This option must be set in the host's main configuration file, not in any sub-modules. During stage-1 evaluation Noxa
          will set the imports = [...] option to an empty list, and evaluate the host's main module to determine the value of this option.
        '';
      };

      agenixRekeySupport = mkOption {
        type = bool;
        default = cfg.externalModuleSupport;
        description = ''
          Enable Agenix Rekey (github:oddlama/agenix-rekey) support in Noxa. The agenix-rekey module will automatically be included to your nixos configuration.
          This will allow you to use Agenix Rekey secrets in your Noxa configurations; enabling secure secret management with rekeying capabilities.

          This option must be set in the host's main configuration file, not in any sub-modules. During stage-1 evaluation Noxa
          will set the imports = [...] option to an empty list, and evaluate the host's main module to determine the value of this option.
        '';
      };
    };
}
