{ noxa, lib, disko, ... }: with lib; {
  config =
    let

      filesInHostDir = noxa.lib.nixDirectoryToAttr' ./hosts;
    in
    {
      defaults = { config, name, lib, ... }: {
        configuration = {
          imports = [
            # Add global nixos modules
            ./shared.nix
            ./hardware/vm.nix
            disko.nixosModules.disko
          ];
          # Set the default hostname based on the file name in `./hosts`
          config.networking.hostName = lib.mkDefault name;
        };
      };

      # Add files located in `./hosts` directory as nodes.
      nodes =
        attrsets.mapAttrs
          (name: path: path)
          filesInHostDir;

      # Add files located in `./hosts` directory as nodes.
      nodeNames = attrsets.mapAttrsToList (name: path: name) filesInHostDir;

      # Define exemplary wireguard network.
      # You will likely remove this, when you use this example as template.
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
