{ nixpkgs
, lib ? nixpkgs.lib
, ...
}@inputs:
with builtins; with lib;
let
  nixDirectoryToList = (import ./nix-dir-listing.nix { inherit nixpkgs; inherit lib; }).nixDirectoryToList;

  nix-files = nixDirectoryToList ./.;
in
(fold (a: b: a // b) { } (map (file: import file inputs) nix-files))
