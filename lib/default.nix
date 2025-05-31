{ nixpkgs
, lib ? nixpkgs.lib
, mkMerge ? lib.mkMerge
, ...
}@inputs:
with builtins; with lib;
let
  nixDirectoryToList = (import ./nix-dir-listing.nix { inherit nixpkgs; inherit lib; }).nixDirectoryToList;

  nix-files = nixDirectoryToList ./.;

  noxa-lib = fold (a: b: a // b) { } (map (file: import file inputs) nix-files);
in
noxa-lib
