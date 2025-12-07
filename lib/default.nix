{ nixpkgs
, lib ? nixpkgs.lib
, ...
}@inputs:
with builtins; with lib;
let
  nixDirectoryToList = (import ./nix-dir-listing.nix { inherit nixpkgs; inherit lib; noxaLib = library; }).nixDirectoryToList;

  nix-files = nixDirectoryToList ./.;
  library = (foldl (a: b: a // b) { } (map (file: import file (inputs // { noxaLib = library; })) nix-files));
in
library
