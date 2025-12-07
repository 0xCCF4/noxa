# Main noxa configuration file
# This is the central configuration file for your multi-host NixOS setup
#
# Like with any NixOS configuration, you can import additional modules,
# define options, etc.
#
# Hosts are defined via the nodes attribute. By default, we import all files
# from the `./hosts` directory as nodes, using their file names as node names.
# To add a new host configuration, just add a new file in the `./hosts` directory.
{ noxa, lib, disko, config, home-manager, ... }: with lib; let
  filesInHostDir = noxa.lib.nixDirectoryToAttr' ./hosts;
in
{
  config = {
    defaults = { config, name, lib, ... }: with lib; {
      configuration = {
        imports = [
          # Add global nixos modules
          ./secrets # Configure secrets management
          home-manager.nixosModules.default # Add home manager to all nodes
        ];

        config = {
          # Set the default hostname based on the file name in `./hosts`
          # If you do not specify a hostname in your nixos config, it uses the noxa node name
          networking.hostName = mkDefault name;

          # Default state version for all nodes
          system.stateVersion = mkDefault "25.11";
        };
      };
    };

    # Add files located in `./hosts` directory as nodes.
    nodes =
      attrsets.mapAttrs
        (name: path: path)
        filesInHostDir;

    # Add files located in `./hosts` directory as nodes.
    nodeNames = attrsets.mapAttrsToList (name: path: name) filesInHostDir;
  };
}
