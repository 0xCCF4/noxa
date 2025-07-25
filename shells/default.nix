{ noxa ? inputs.self
, nixpkgs
, lib ? nixpkgs.lib
, ...
}@inputs:
with lib; with builtins;
noxa.lib.nixDirectoryToAttr' ./.
