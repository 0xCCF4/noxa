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
    routes = mkOption {
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
              peers = mkOption {
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
                  A list of peers for this interface. Automatically populated.
                '';
              };
              neighbors = mkOption {
                type = lazyAttrsOf (submodule (submod: {
                  options = {
                    keepAlive = mkOption {
                      type = nullOr int;
                      readOnly = true;
                      description = ''
                        The keep-alive interval for this connection, in seconds.
                        If set to `null`, no keep-alive is configured.
                      '';
                    };
                  };
                }));
                readOnly = true;
                description = ''
                  A set of connections for this interface, automatically computed from the nixos configurations.
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
      noxa.wireguard.routes = mkMerge (map
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

            minOrNull = (a: b: if a == null then b else if b == null then a else min a b);
          in
          {
            "${name}" = {
              peers = mkMerge [
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
              neighbors = mkMerge (map
                (via: {
                  "${via}" = {
                    keepAlive = minOrNull allmod.${via}.advertise.keepAlive submod.keepAlive;
                  };
                })
                (lists.unique ((map (peer: if peer.via == config.networking.hostName then peer.target else peer.via) config.noxa.wireguard.routes.${name}.peers))));
              participants.servers = attrNames servers;
              participants.clients = attrNames clients;
              participants.gateways = attrNames gateways;
            };
          })
        (attrNames cfg.interfaces));
    };
}
