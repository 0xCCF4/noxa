{
  nixpkgs,
  lib ? nixpkgs.lib,
  mkMerge ? lib.mkMerge,
  ...
}@inputs:
with builtins; with lib;
let
  list-nix-directory = (import ./nix-dir-listing.nix { inherit nixpkgs; inherit lib; }).list-nix-directory;

  nix-files = list-nix-directory ./.;

  noxa-lib = fold (a: b: a//b) {} (map (file: import file inputs) nix-files);
in
noxa-lib