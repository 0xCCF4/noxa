{ config, noxa, lib, nodes, ... }:
with builtins; with lib; let
  template = backend: name:
    let
      ourSecrets = config.noxa.wireguard.secrets.${name};
      ourConfig = config.noxa.wireguard.interfaces.${name};
      routes = config.noxa.wireguard.routes.${name};

      peers = attrsets.mapAttrs
        (neighbor: cfg:
          let
            otherHost = nodes.${neighbor}.noxa.wireguard.interfaces.${name};
            otherSecrets = nodes.${neighbor}.noxa.wireguard.secrets.${name};
          in
          {
            allowedIPs = otherHost.deviceAddresses ++ (lists.optional (elem neighbor routes.participants.gateways) ourConfig.networkAddress);
            persistentKeepalive = mkIf (cfg.keepAlive != null) cfg.keepAlive;
            endpoint = mkIf (otherHost.advertise.server != null) "${otherHost.advertise.server.listenAddress or "<invalid>"}:${toString otherHost.advertise.server.listenPort or "<invalid>"}";
            publicKey = otherSecrets.publicKey;
            name = neighbor;
            presharedKeyFile = ourSecrets.presharedKeyFiles.${neighbor};
          })
        routes.neighbors;

      ips =
        if backend == "wg-quick"
        then {
          address = ourConfig.deviceAddresses;
        } else {
          ips = ourConfig.deviceAddresses;
        };

      peersWgQuick = map (peer: removeAttrs peer [ "name" ]) peers;
    in
    {
      privateKeyFile = ourSecrets.privateKeyFile;
      listenPort = mkIf (ourConfig.advertise.server != null) (ourConfig.advertise.server.listenPort or "<invalid>");
      peers = attrValues (if backend == "wg-quick" then peersWgQuick else peers);
    } // ips;
in
{
  config = {
    networking.wireguard.interfaces = mkMerge (attrsets.mapAttrsToList
      (name: cfg: {
        "${name}" = mkIf (cfg.backend == "wireguard") (template cfg.backend name);
      })
      config.noxa.wireguard.interfaces);

    networking.wg-quick.interfaces = mkMerge (attrsets.mapAttrsToList
      (name: cfg: {
        "${name}" = mkIf (cfg.backend == "wg-quick") (template cfg.backend name);
      })
      config.noxa.wireguard.interfaces);
  };
}
