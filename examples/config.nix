{ noxa, lib, disko, ... }: with lib; {
  config =
    let
      filesInHostDir = (attrsets.mapAttrs'
        (name: path: attrsets.nameValuePair (noxa.lib.filesystem.baseNameWithoutExtension name) path)
        (noxa.lib.nixDirectoryToAttr ./hosts));
    in
    {
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
        attrsets.mapAttrs
          (name: path: path)
          filesInHostDir;

      nodeNames = attrsets.mapAttrsToList (name: path: name) filesInHostDir;

      wireguard = {
        wg-service = {
          networkAddress = "10.0.0.0/24";
          members = {
            hostA = {
              deviceAddresses = [ "10.0.0.1/32" ];
              advertise.server = {
                listenPort = 51820;
                listenAddress = "1.1.1.1";
                defaultGateway = true;
              };
            };
            hostB = {
              deviceAddresses = [ "10.0.0.2/32" ];
            };
            hostC = {
              deviceAddresses = [ "10.0.0.3/32" ];
            };
            hostD = {
              deviceAddresses = [ "10.0.0.4/32" ];
              advertise.server = {
                listenPort = 51820;
                listenAddress = "2.2.2.2";
              };
            };
          };
        };
      };
    };
}
