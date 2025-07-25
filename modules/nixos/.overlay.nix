{ config, lib, ... }: with lib; with lib.types; {
  options.noxa.overlays = mkOption {
    type = listOf anything; # make this func of kind `final: prev: ... -> { ... }`
    default = [ ];
    description = ''
      A list of overlays to apply to this nixos configuration. The inputs being the final
      output and the build results from the stage-1 evaluation of the NixOS configuration.

      Evaluated by the `noxa.lib.nixos-instantiate` function.

      Type of each entry in the list is a function of kind `{final, prev, stageOne} -> { ... }`.
        - `final`: the final output of the NixOS configuration, which is the result of the stage-2 evaluation.
        - `prev`: the previous output of the previous overlay, view of the stage-2 evaluation.
        - `stageOne`: the output of the stage-1 evaluation, which is the result of the first evaluation of the NixOS configuration.
    '';
  };
}
