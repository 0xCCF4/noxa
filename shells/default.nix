{
  noxa-lib ? inputs.self.lib.noxa-lib,
  nixpkgs,
  lib ? nixpkgs.lib,
  ...
}@inputs:
with lib; with builtins; with lib.attrsets;
let
    shellPaths = noxa-lib.list-nix-directory ./.;
in
    mapAttrs (key: value: value.contents) (mkMerge (map (path: let
        name = baseNameOf path;
    in {
        "${name}" = import path inputs;
        }) shellPaths))