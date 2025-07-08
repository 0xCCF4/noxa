{ noxa, lib, disko, ... }: with lib; {
  config = {
    defaults = { config, name, lib, ... }: {
      configuration = {
        imports = [
          ./shared.nix
          ./hardware/vm.nix
          disko.nixosModules.disko
        ];
        config.networking.hostName = lib.mkDefault "${name}-hostname";
      };
    };

    nodes =
      let
        filesInHostDir = (attrsets.mapAttrs'
          (name: path: attrsets.nameValuePair (noxa.lib.filesystem.baseNameWithoutExtension name) path)
          (noxa.lib.nixDirectoryToAttr ./hosts));
      in
      attrsets.mapAttrs
        (name: path: path)
        filesInHostDir;
  };
}
