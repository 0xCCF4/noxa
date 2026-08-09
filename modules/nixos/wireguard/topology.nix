/**
  Pulls this host's share of the cross-host topology declared through
  `noxa.wireguard` (see `modules/flake-parts/wireguard.nix`) into this
  host's own `noxa.wireguard.interfaces` option.
*/
{ config, lib, noxa, ... }: with lib; with builtins; let
  noxaHost = config.networking.hostName;

  networksNodeIsContainedIn = attrsets.filterAttrs
    (networkName: netConfig: elem noxaHost (attrNames netConfig.members))
    noxa.wireguard;

  setIfNotNull = value: mkIf (value != null) value;
in
{
  config = {
    noxa.wireguard.interfaces = attrsets.mapAttrs
      (networkName: netConfig:
        let
          member = netConfig.members.${noxaHost};
        in
        {
          networkAddress = netConfig.networkAddress;
          autostart = setIfNotNull member.autostart;
          backend = setIfNotNull member.backend;
          deviceAddresses = setIfNotNull member.deviceAddresses;
          advertise.server = mkIf (member.advertise.server != null) {
            listenPort = setIfNotNull member.advertise.server.listenPort;
            listenAddress = setIfNotNull member.advertise.server.listenAddress;
            defaultGateway = setIfNotNull member.advertise.server.defaultGateway;
            firewallAllow = setIfNotNull member.advertise.server.firewallAllow;
          };
          advertise.keepAlive = setIfNotNull member.advertise.keepAlive;
          keepAlive = setIfNotNull member.keepAlive;
          gatewayOverride = setIfNotNull member.gatewayOverride;
        })
      networksNodeIsContainedIn;

    assertions = with noxa.lib.ansi;
      (attrsets.mapAttrsToList
        (networkName: netConfig: {
          assertion = !netConfig.members.${noxaHost}.onlySpecifiedDeviceAddresses ||
            (config.noxa.wireguard.interfaces.${networkName}.deviceAddresses == netConfig.members.${noxaHost}.deviceAddresses);
          message = "${fgYellow}Node ${fgCyan}'${noxaHost}'${fgYellow} sets device addresses ${fgGreen}${toJSON (config.noxa.wireguard.interfaces.${networkName}.deviceAddresses or [ ])}${fgYellow} for network ${fgCyan}'${networkName}'${fgYellow}, but the network requires the stated device addresses ${fgGreen}${toJSON netConfig.members.${noxaHost}.deviceAddresses}${fgYellow}.${default}";
        })
        networksNodeIsContainedIn)
      ++
      (map
        (networkName: {
          assertion = noxa.wireguard.${networkName}.allowNodesToJoin || (elem noxaHost (attrNames noxa.wireguard.${networkName}.members));
          message = "${fgYellow}Node ${fgCyan}'${noxaHost}'${fgYellow} is not allowed to join the locked network ${fgCyan}'${networkName}'${fgYellow}.${default}";
        })
        (filter (name: hasAttr name noxa.wireguard) (attrNames config.noxa.wireguard.interfaces)));
  };
}
