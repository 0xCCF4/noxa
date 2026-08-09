{ config, lib, self, noxaFlake, nixNetLib, ... }: with lib; {
  options.noxa.managedNodes = mkOption {
    type = types.listOf types.str;
    default = attrsets.attrNames config.ezConfigs.nixos.hosts;
    description = ''
      Names of the NixOS hosts managed by Noxa. Defaults to every host
      ez-configs discovers. Narrow this list to exclude hosts that should
      not join the Noxa mesh, for example an ISO installer configuration.
    '';
  };

  config.ezConfigs.nixos.specialArgs = lib.asserts.checkAssertWarn config.assertions config.warnings {
    inherit self;
    noxa = noxaFlake // {
      lib = noxaFlake.lib // { net = nixNetLib; };
      managedNodes = config.noxa.managedNodes;
      wireguard = config.noxa.wireguard;
    };
  };
}
