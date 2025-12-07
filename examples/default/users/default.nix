{ inputs, lib, ... }: with lib; with builtins; let
  modules = removeAttrs (inputs.noxa.lib.nixDirectoryToAttr' ./.) [ "default" ];
  uidMapping = fromJSON (readFile ./_mapping.json);
in
{
  flake = {
    users = mapAttrs
      (name: module: (import module inputs) // {
        uid = uidMapping.${name} or (throw "No UID mapping for user: ${name}");
      })
      modules;
  };
}
