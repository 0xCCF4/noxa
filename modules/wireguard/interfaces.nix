{ config, noxa, lib, ... }:
with builtins; with lib; let
  template = backend: name:
    let
      ourSecrets = config.noxa.wireguard.secrets.${name};
      ourConfig = config.noxa.wireguard.interfaces.${name};
      routes = config.noxa.wireguard.routes.${name};

      peers = attrsets.mapAttrs
        (neighbor: cfg:
          let
            otherHost = noxa.nixosConfigurations.${neighbor}.config.noxa.wireguard.interfaces.${name};
            otherSecrets = noxa.nixosConfigurations.${neighbor}.config.noxa.wireguard.secrets.${name};
          in
          {
            allowedIPs = otherHost.deviceAddresses ++ (lists.optional (elem neighbor routes.participants.gateways) ourConfig.networkAddress);
            persistentKeepalive = mkIf (cfg.keepAlive != null) cfg.keepAlive;
            endpoint = mkIf (otherHost.advertise.server != null) "${otherHost.advertise.server.listenAddress or "<invalid>"}:${toString otherHost.advertise.server.listenPort or "<invalid>"}";
            name = mkIf (backend == "wireguard") neighbor;
            publicKey = otherSecrets.publicKey;
            presharedKeyFile = ourSecrets.presharedKeyFiles.${neighbor};
          })
        routes.neighbors;
    in
    {
      privateKeyFile = ourSecrets.privateKeyFile;
      listenPort = mkIf (ourConfig.advertise.server != null) (ourConfig.advertise.server.listenPort or "<invalid>");
      ips = ourConfig.deviceAddresses;
      peers = attrValues peers;
    };
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
