{ config, noxa, lib, self, ... }:
with builtins; with lib; let
  template = backend: name:
    let
      ourSecrets = config.noxa.wireguard.secrets.${name};
      ourConfig = config.noxa.wireguard.interfaces.${name};
      routes = config.noxa.wireguard.routes.${name};

      peers = attrsets.mapAttrs
        (neighbor: cfg:
          let
            otherHost = self.nixosConfigurations.${neighbor}.config.noxa.wireguard.interfaces.${name};
            otherSecrets = self.nixosConfigurations.${neighbor}.config.noxa.wireguard.secrets.${name};
          in
          {
            allowedIPs = otherHost.deviceAddresses
              ++ otherHost.advertise.routes
              # networks behind peers reached through this neighbor (as gateway)
              ++ (concatMap (peer: self.nixosConfigurations.${peer.target}.config.noxa.wireguard.interfaces.${name}.advertise.routes)
              (filter (peer: peer.via == neighbor && peer.target != neighbor) routes.peers))
              ++ (lists.optionals (elem neighbor routes.participants.gateways)
              ([ ourConfig.networkAddress ] ++ lists.optional (ourConfig.networkAddress6 != null) ourConfig.networkAddress6));
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

      peersWgQuick = attrsets.mapAttrs (name: peer: removeAttrs peer [ "name" ]) peers;
    in
    {
      privateKeyFile = ourSecrets.privateKeyFile;
      listenPort = mkIf (ourConfig.advertise.server != null) (ourConfig.advertise.server.listenPort or "<invalid>");
      peers = attrValues (if backend == "wg-quick" then peersWgQuick else peers);
    } // ips;
in
{
  config = mkIf (!(config.age.rekey.initialRollout or false)) {
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

    networking.firewall.allowedUDPPorts = mkMerge (attrsets.mapAttrsToList
      (name: cfg: mkIf (cfg.advertise.server != null && cfg.advertise.server.firewallAllow)
        [ cfg.advertise.server.listenPort ]
      )
      config.noxa.wireguard.interfaces);
  };
}
