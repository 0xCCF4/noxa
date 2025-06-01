{ noxa ? inputs.self
, nixpkgs
, lib ? nixpkgs.lib
, ...
}@inputs:
with lib; with builtins;
let
  shellPaths = noxa.lib.nixDirectoryToAttr ./.;
in
(attrsets.mapAttrs'
  (name: path: attrsets.nameValuePair (noxa.lib.baseNameWithoutExtension name) (import path inputs))
  shellPaths)
