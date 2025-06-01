{ pkgs
, config
, lib
, noxa
, ...
}:
with lib; with builtins; with types; with types.net;
{
  options.noxa.wireguard = {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enables the WireGuard module, which a cross-host VPN setup utility for wireguard.
      '';
    };

    interfaces = mkOption {
      type = attrsOf (submodule (self: {
        options = {
          networkAddress = mkOption {
            type = listOf ipNetwork;
            description = "The network IP addresses";
          };

          autostart = mkOption {
            type = bool;
            default = true;
            description = "Specifies whether to autostart the WireGuard interface and which IP version to use.";
          };

          backend = mkOption {
            type = enum [ "wireguard" "wg-quick" ];
            default = "wireguard";
            description = "The backend to use for WireGuard config generation";
          };

          deviceAddresses = mkOption {
            type = listOf ip;
            description = "The device IP addresses";
          };

          listenPort = mkOption {
            type = nullOr int;
            default = null;
            description = "The port for WireGuard to listen for incoming connections";
          };

          addFirewallAllow = mkOption {
            type = bool;
            default = true;
            description = "Add firewall rule to allow traffic for listenPort";
          };

          listenAddress = mkOption {
            type = nullOr ip;
            default = null;
            description = "The address for WireGuard to listen for incoming connections";
          };

          remoteKeepAlive = mkOption {
            type = nullOr int;
            default = null;
            description = "The keep alive interval remote peers should use";
          };

          localKeepAlive = mkOption {
            type = nullOr int;
            default = null;
            description = "The keep alive interval this interface will use, if remoteKeepAlive is set, this will use the minimum of both";
          };

          isServer = mkOption {
            type = bool;
            default = self.config.listenAddress != null;
            description = "Specifies whether this peer is a server";
            readOnly = true;
          };

          additionalPeers = mkOption {
            type = listOf anything;
            default = [ ];
            description = "Additional peers to add to the WireGuard interface";
          };
        };
      }));
      default = { };
      description = ''
        A set of WireGuard interfaces to configure. Each interface is defined by its name and
        contains its private key, public key, and listen port.
      '';
    };

    secrets = mkOption {
      type = attrsOf (submodule (self: {
        options = {
          presharedKeyFile = mkOption {
            type = str;
            readOnly = true;
            description = "The pre-shared key file for WireGuard";
          };

          publicKey = mkOption {
            type = str;
            readOnly = true;
            description = "The public key for WireGuard";
          };

          privateKeyFile = mkOption {
            type = str;
            readOnly = true;
            description = "The private key file for WireGuard";
          };
        };
      }));
      default = { };
      description = ''
        A set of wireguard secrets. When using the `.interfaces` options,
        this set is automatically populated. Each peer will own its own
        set of secrets
      '';
    };
  };
}
