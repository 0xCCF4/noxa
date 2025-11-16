{ lib, noxa, config, ... }: with lib; with builtins; {
  options = with types; {
    nixpkgs = mkOption {
      type = path;
      description = ''
        The nixpkgs version to use when building this node.

        By default, if not explicitly set, it uses the same version than the Noxa flake itself.
      '';
      default = if (noxa.__buildDocs or false) then mkLiteral "<nixpkgs>" else noxa.nixpkgs;
    };
    pkgs = mkOption {
      type = raw;
      description = ''
        The pkgs set with overlays and for the target system of this node.
      '';
      default = config.configuration.pkgs;
      readOnly = true;
    };
  };
}
