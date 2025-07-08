{ pkgs
, config
, lib
, noxa
, ...
}:
with lib; with builtins; with types; with noxa.lib.net.types;
let
  cfg = config.noxa.wireguard;
in
{
  options.noxa.wireguard = {
    enable = mkOption {
      type = bool;
      default = cfg.interfaces != { };
      description = ''
        Enables the WireGuard module, which a cross-host VPN setup utility for wireguard.
      '';
    };

    interfaces = mkOption {
      type = lazyAttrsOf (submodule (submod: {
        options = {
          networkAddress = mkOption {
            type = ipNetwork;
            description = ''
              The network IP addresses. On clients, traffic of this network will be routed through the WireGuard interface.
            '';
          };

          autostart = mkOption {
            type = bool;
            default = true;
            description = ''
              Specifies whether to autostart the WireGuard interface.

              Only relevant if the `backend` is set to `wg-quick`.
            '';
          };

          backend = mkOption {
            type = enum [ "wireguard" "wg-quick" ];
            default = "wireguard";
            description = ''
              The backend to use for WireGuard config generation.
              - `wireguard`: Uses the `networking.wireguard.interfaces` module to generate the configuration.
              - `wg-quick`: Uses the `networking.wg-quick.interfaces` module to generate the configuration.
            '';
          };

          deviceAddresses = mkOption {
            type = listOf ip;
            description = ''
              List of ip addresses to assign to this interface. The server will forward traffic
              to these addresses.
            '';
          };

          advertise.server = mkOption {
            type = nullOr (submodule (submod: {
              options = {
                listenPort = mkOption {
                  type = int;
                  description = ''
                    The port this server will listen on for incoming connections.
                  '';
                };

                listenAddress = mkOption {
                  type = ip;
                  description = ''
                    The address this server will listen on for incoming connections.
                  '';
                };

                defaultGateway = mkOption {
                  type = bool;
                  default = false;
                  description = ''
                    If set, this server will be the default gateway for clients.
                  '';
                };

                firewallAllow = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    If set, the nixos firewall will allow incoming connections to the advertised listen port.
                  '';
                };
              };
            }));
            default = null;
            description = ''
              Options for wireguard servers. If a wireguard interface is regarded as a server (e.g. since it has a public IP address), it may advertise its service via the `server.advertise` option.

              If set, all peers that would like to connect to that peer will use the advertised listen port and address as means of directly connecting to the server.

              Further, if `server.defaultGateway` is set, all peers that do not advertise listen port and address will be reached via the server marked as default gateway. Therefore, only one interface may be marked as default gateway at any time.
            '';
          };

          kind.isServer = mkOption {
            type = bool;
            readOnly = true;
            default = submod.config.advertise.server != null;
            description = ''
              This interface has the role of a server, meaning it advertises its listen port and address to peers.
            '';
          };

          kind.isClient = mkOption {
            type = bool;
            readOnly = true;
            default = !submod.config.kind.isServer;
            description = ''
              This interface has the role of a client, meaning it does not advertise other peers to connect to it. Instead, it connects to other peers, initiating the connection.
            '';
          };

          kind.isGateway = mkOption {
            type = bool;
            readOnly = true;
            default = submod.config.kind.isServer && submod.config.advertise.server.defaultGateway;
            description = ''
              This interface is a server and is marked as the default gateway for clients.
              This means that clients will use this interface to reach other peers that do not advertise their listen port and address.
            '';
          };

          advertise.keepAlive = mkOption {
            type = nullOr int;
            default = null;
            description = ''
              The keep alive interval remote peers should use when communicating with this interface.
            '';
          };

          keepAlive = mkOption {
            type = nullOr int;
            default = null;
            description = ''
              The default keep alive interval this interface will use when communicating with remote peers.

              If the remote end uses `advertise.keepAlive`, the minimum value of both will be used.
            '';
          };

          gatewayOverride = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              If set, this interface will use the specified hostname as the gateway for connecting to the wireguard network.
            '';
          };
        };
      }));
      default = { };
      description = ''
        A set of WireGuard interfaces to configure. Each interface is defined by its name and
        contains its private key, public key, and listen port.
      '';
    };
  };
}
