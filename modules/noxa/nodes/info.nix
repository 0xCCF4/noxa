{ noxa, lib, config, name, ... }: with lib; with builtins; {
  options = with types; with noxa.lib.net.types; {

    reachable.internet = mkOption {
      type = listOf ip;
      description = "List of external IP addresses this host is reachable at via using a public IP address.";
      default = [ ];
    };

    reachable.wireguardNetwork = mkOption {
      type = attrsOf (listOf ip);
      description = "List of IP addresses this host is reachable at via WireGuard (specified via name).";
      default = { };
    };

    reachable.allowHostConfiguration = mkOption {
      type = bool;
      default = false;
      description = "Allow the host to configure its own reachable addresses. If set to false, values can only be set on the Noxa module level.";
    };
  };

  config = {
    assertions = with noxa.lib.ansi; (attrsets.mapAttrsToList
      (netName: ip: {
        assertion = hasAttr netName noxaConfig.wireguard;
        message = "${fgYellow}The host ${fgCyan}${name}${fgYellow} defines a reachability via a WireGuard network ${fgCyan}${netName}${fgYellow}, but the Noxa module does not declare a WireGuard network with that name.${default}";
      })
      config.reachable.wireguardNetwork);
  };
}
