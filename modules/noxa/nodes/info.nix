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
    configuration.noxa.info = {
      reachable.internet = config.reachable.internet;
      reachable.wireguardNetwork = config.reachable.wireguardNetwork;
    };

    assertions = with noxa.lib.ansi; [
      {
        assertion = !config.reachable.allowHostConfiguration -> (config.reachable.internet == config.configuration.noxa.info.reachable.internet);
        message = "${fgYellow}The host ${fgCyan}${name}${fgYellow} defines its own reachable addresses ${fgCyan}${toJSON config.configuration.noxa.info.reachable.internet}${fgYellow}, but the Noxa module it set to not allow this, it has configured them as ${fgCyan}${toJSON config.reachable.internet}${fgYellow}.${default}";
      }
      {
        assertion = !config.reachable.allowHostConfiguration -> (config.reachable.wireguardNetwork == config.configuration.noxa.info.reachable.wireguardNetwork);
        message = "${fgYellow}The host ${fgCyan}${name}${fgYellow} defines its own reachable WireGuard addresses ${fgCyan}${toJSON config.configuration.noxa.info.reachable.wireguardNetwork}${fgYellow}, but the Noxa module it set to not allow this, it has configured them as ${fgCyan}${toJSON config.reachable.wireguardNetwork}${fgYellow}.${default}";
      }
    ] ++ (attrsets.mapAttrsToList
      (netName: ip: {
        assertion = hasAttr netName noxaConfig.wireguard;
        message = "${fgYellow}The host ${fgCyan}${name}${fgYellow} defines a reachability via a WireGuard network ${fgCyan}${netName}${fgYellow}, but the Noxa module does not declare a WireGuard network with that name.${default}";
      })
      config.reachable.wireguardNetwork);
  };
}
