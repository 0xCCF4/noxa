{ pkgs
, config
, lib
, noxa
, ...
}:
with lib; with builtins; with types; with noxa.net.types;
let
  cfg = config.noxa.wireguard;
in
{
  options.noxa.wireguard = {
    data = mkOption {
      type = lazyAttrsOf
        (submodule
          (submod: {
            options = {
              participants.servers = mkOption {
                type = listOf str;
                readOnly = true;
                description = ''
                  A list of servers for this interface. Automatically populated.
                '';
              };
              participants.clients = mkOption {
                type = listOf str;
                readOnly = true;
                description = ''
                  A list of clients for this interface. Automatically populated.
                '';
              };
              participants.gateways = mkOption {
                type = listOf str;
                readOnly = true;
                description = ''
                  A list of gateways for this interface. Automatically populated.
                '';
              };
              connections = mkOption {
                type = listOf (submodule (submod: {
                  options = {
                    target = mkOption {
                      type = str;
                      readOnly = true;
                      description = ''
                        The target hostname of the connection.
                      '';
                    };
                    via = mkOption {
                      type = nullOr str;
                      readOnly = true;
                      description = ''
                        The hostname of the peer this connection is routed through.
                      '';
                    };
                  };
                }));

                readOnly = true;
                description = ''
                  A list of connections for this interface. Automatically populated.
                '';
              };
            };
          }));
      description = ''
        A set of intermediary connection information, automatically computed from the nixos configurations.
      '';
      readOnly = true;
    };
  };

  config =
    let
      allmods = name: mapAttrs (key: value: value.config.noxa.wireguard.interfaces."${name}") (attrsets.filterAttrs (host: nixos: attrsets.hasAttrByPath [ "config" "noxa" "wireguard" "interfaces" name ] nixos) noxa.nixosConfigurations);
      exceptThis = attrsets.filterAttrs (host: nixos: host != config.networking.hostName) allmods;
    in
    {
      noxa.wireguard.data = mkMerge (map
        (name:
          let
            submod = cfg.interfaces.${name};
            allmod = allmods name;

            gateways = attrsets.filterAttrs (host: mod: mod.kind.isGateway) allmod;
            clients = attrsets.filterAttrs (host: mod: mod.kind.isClient) allmod;
            servers = attrsets.filterAttrs (host: mod: mod.kind.isServer) allmod;

            gatewaysListOrdered = lists.sort (a: b: a < b) (attrNames gateways);

            gateway =
              if submod.gatewayOverride != null
              then submod.gatewayOverride
              else if length gatewaysListOrdered > 0 then
                head gatewaysListOrdered
              else
                null;
          in
          {
            "${name}" = {
              connections = mkMerge [
                (attrsets.mapAttrsToList
                  (host: config: {
                    target = host;
                    via = host;
                  })
                  (attrsets.filterAttrs (host: mod: host != config.networking.hostName) servers))

                (attrsets.mapAttrsToList
                  (host: config: {
                    target = host;
                    via = gateway;
                  })
                  (attrsets.filterAttrs (host: mod: host != config.networking.hostName) clients))
              ];
              participants.servers = attrNames servers;
              participants.clients = attrNames clients;
              participants.gateways = attrNames gateways;
            };
          })
        (attrNames cfg.interfaces));
    };
}
