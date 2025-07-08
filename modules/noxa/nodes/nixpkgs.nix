{ lib, noxa, ... }: with lib; with builtins; {
  options = with types; {
    nixpkgs = mkOption {
      type = path;
      description = ''
        The nixpkgs version to use when building this node.

        By default, if not explicitly set, it uses the same version than the Noxa flake itself.
      '';
      default = noxa.nixpkgs;
    };
  };
}
