{ lib, noxa, config, ... }: with lib; with builtins; {
  options = with types; {
    nixpkgs = mkOption {
      type = path;
      description = ''
        The nixpkgs version to use when building this node.

        By default, if not explicitly set, it uses the same version than the Noxa flake itself.
      '';
      default = noxa.nixpkgs;
      defaultText = "<nixpkgs>";
    };
    pkgs = mkOption {
      type = raw;
      description = ''
        The pkgs set with overlays and for the target system of this node.
      '';
      default = config.configuration.pkgs;
      defaultText = "<pkgs>";
      readOnly = true;
    };
    options = mkOption {
      type = raw;
      description = ''
        The contents of the options defined by the nixpkgs module for this node.
      '';
      default = config.configuration.options;
      defaultText = "<options>";
      readOnly = true;
    };
  };
}
