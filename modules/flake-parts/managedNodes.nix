{ config, lib, self, noxaFlake, nixNetLib, ... }: with lib; {
  options.noxa.managedNodes = mkOption {
    type = types.listOf types.str;
    # `ezConfigs.nixos.hosts` only holds per-host settings overrides, the
    # discovered hosts are the built configurations
    default = attrsets.attrNames config.flake.nixosConfigurations;
    defaultText = literalExpression "attrNames config.flake.nixosConfigurations";
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
      ula = config.noxa.ula;
    };
  };
}
