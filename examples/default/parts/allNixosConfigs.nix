{ inputs, lib, self, ... }: with lib;
{
  perSystem = { pkgs, system, ... }: {
    packages.allNixosConfigs = pkgs.linkFarm "all-nixos-configs"
      (mapAttrsToList (host: node: { name = host; path = node.config.system.build.toplevel; }) self.nixosConfigurations);
  };
}
