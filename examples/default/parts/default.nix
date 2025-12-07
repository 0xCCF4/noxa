{ inputs, lib, ... }: with lib; let
  modules = inputs.noxa.lib.nixDirectoryToAttr' ./.;
  noDefault = filterAttrs (name: value: name != "default") modules;
in
{
  imports = (attrValues noDefault) ++ [
    ../modules/nixos/default.nix
    ../modules/noxa/default.nix
    ../modules/home/default.nix
    ../users/default.nix
    ../packages/default.nix
  ];
}
