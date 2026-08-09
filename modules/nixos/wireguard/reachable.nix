{ lib, config, noxa, ... }: with lib; with builtins; let
  noxaHost = config.networking.hostName;
in
{
  options.noxa.wireguard.reachable = with types; with noxa.lib.net.types; {
    internet = mkOption {
      type = listOf ip;
      description = "External IP addresses this host is reachable at over the public internet.";
      default = [ ];
    };

    wireguardNetwork = mkOption {
      type = attrsOf (listOf ip);
      description = "IP addresses this host is reachable at over an existing WireGuard network, keyed by network name.";
      default = { };
    };
  };

  config.assertions = with noxa.lib.ansi; attrsets.mapAttrsToList
    (netName: ip: {
      assertion = hasAttr netName noxa.wireguard;
      message = "${fgYellow}Host ${fgCyan}${noxaHost}${fgYellow} declares reachability over WireGuard network ${fgCyan}${netName}${fgYellow}, but Noxa does not declare a WireGuard network with that name.${default}";
    })
    config.noxa.wireguard.reachable.wireguardNetwork;
}
