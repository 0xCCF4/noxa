{ inputs, lib, ... }: with lib; let
  packageList = inputs.noxa.lib.nixDirectoryToAttr' ./.;
  modules = filterAttrs (name: value: name != "default") packageList;
  packages = pkgs: config: mapAttrs (name: value: pkgs.callPackage value { }) modules;
in
{
  perSystem = { config, pkgs, final, ... }: {
    packages = packages pkgs config;
  };
}
