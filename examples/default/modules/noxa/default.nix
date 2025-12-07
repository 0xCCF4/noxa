{ inputs, lib, ... }: with lib; let
  modules = inputs.noxa.lib.nixDirectoryToAttr' ./.;
in
{
  flake = {
    noxaModules = modules // {
      default = { ... }: {
        imports = attrValues (filterAttrs (name: value: name != "default") modules);
      };
    };
  };
}
