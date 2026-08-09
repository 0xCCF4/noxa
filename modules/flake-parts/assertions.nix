/**
  flake-parts has no built-in `assertions`/`warnings` option (that's a
  NixOS-specific module). Declare the same shape here so Noxa's own
  flake-parts options can report configuration errors.
*/
{ lib, ... }: with lib; {
  options = {
    assertions = mkOption {
      type = types.listOf types.unspecified;
      default = [ ];
      description = "Assertions checked before Noxa wires up its specialArgs.";
      internal = true;
    };

    warnings = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Warnings shown before Noxa wires up its specialArgs.";
      internal = true;
    };
  };
}
