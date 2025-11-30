{ lib, pkgs, noxa, ... }: with builtins; with lib; {
  options = with types; {
    pkgs = mkOption {
      type = raw;
      description = ''
        The pkgs variable, useful for package lookups inside Noxa modules.
      '';
      readOnly = true;
      default = pkgs;
      defaultText = "<pkgs>";
    };
  };
}
