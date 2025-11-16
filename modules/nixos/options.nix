{ lib, options, noxa, ... }: with builtins; with lib; {
  options = with types; {
    options = mkOption {
      type = raw;
      description = ''
        The options set, useful for package lookups for options.
      '';
      readOnly = true;
      default = if (noxa.__buildDocs or false) then "<options>" else options;
    };
  };
}
