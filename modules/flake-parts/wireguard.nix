/**
  Cross-host WireGuard network topology.

  This declares the network shape once (which hosts belong to which
  network, who is the gateway, and so on). Each managed host pulls its
  own share of this topology into its NixOS config through the
  `noxa.nixosModules.wireguard` module (see
  `modules/nixos/wireguard/topology.nix`), which reads this option back
  through the `noxa` specialArg.
*/
{ config, lib, self, noxaFlake, ... }: with builtins; with lib; {
  options.noxa.wireguard = mkOption {
    description = "Cross-host WireGuard network topology managed by Noxa.";
    default = { };
    type = types.attrsOf
      (types.submodule
        (network: {
          options = with noxaFlake.lib.net.types; {
            networkAddress = mkOption {
              type = ipNetwork;
              description = "The network address of the WireGuard network.";
            };

            allowNodesToJoin = mkOption {
              type = types.bool;
              default = false;
              description = ''
                If true, a host may join this network by declaring
                `noxa.wireguard.interfaces.<name>` itself.
                If false, a host may only join this network by being listed
                in this network's `members`.
              '';
            };

            autoConfigureGateway = mkOption {
              type = types.bool;
              default = true;
              description = ''
                If true, Noxa configures gateways for this network
                automatically, using each member's
                `noxa.wireguard.reachable.internet` NixOS option.
              '';
            };

            members = mkOption {
              type = types.attrsOf (types.submodule ({ name, ... }: {
                options = {
                  autostart = mkOption {
                    type = types.nullOr types.bool;
                    default = null;
                    description = ''
                      Whether to autostart the WireGuard interface.
                      Only relevant if `backend` is `wg-quick`.
                      Noxa applies a non-null value to the host configuration.
                    '';
                  };

                  backend = mkOption {
                    type = types.nullOr (types.enum [ "wireguard" "wg-quick" ]);
                    default = "wireguard";
                    description = ''
                      The backend to generate the WireGuard config with.
                      - `wireguard`: uses `networking.wireguard.interfaces`.
                      - `wg-quick`: uses `networking.wg-quick.interfaces`.
                      Noxa applies a non-null value to the host configuration.
                    '';
                  };

                  deviceAddresses = mkOption {
                    type = types.nullOr (types.coercedTo ip toList (types.listOf ip));
                    default = null;
                    description = ''
                      IP addresses to assign to this interface. The server
                      forwards traffic to these addresses.
                    '';
                  };

                  onlySpecifiedDeviceAddresses = mkOption {
                    type = types.bool;
                    default = true;
                    description = ''
                      If true, Noxa rejects device addresses the host sets itself.
                      If false, the host may add device addresses to the interface.
                    '';
                  };

                  advertise.server = mkOption {
                    type = types.nullOr (types.submodule {
                      options = {
                        listenPort = mkOption {
                          type = types.nullOr types.int;
                          default = null;
                          description = "The port this server listens on for incoming connections.";
                        };

                        listenAddress = mkOption {
                          type = types.nullOr ip;
                          default = null;
                          description = "The address this server listens on for incoming connections.";
                        };

                        defaultGateway = mkOption {
                          type = types.nullOr types.bool;
                          default = null;
                          description = "If set, this server is the default gateway for clients.";
                        };

                        firewallAllow = mkOption {
                          type = types.nullOr types.bool;
                          default = null;
                          description = ''
                            If set, the NixOS firewall allows incoming connections to the
                            advertised listen port. Noxa applies a non-null value to the
                            host configuration.
                          '';
                        };
                      };
                    });
                    default = null;
                    description = ''
                      Options for WireGuard servers. A WireGuard interface with a public
                      address advertises its service through `advertise.server`.

                      Peers that connect to this server use the advertised listen port
                      and address to reach it directly.

                      If `advertise.server.defaultGateway` is set, peers that do not
                      advertise a listen port and address reach other peers through the
                      interface marked as default gateway. Only one interface may be the
                      default gateway at a time.

                      Noxa applies a non-null value to the host configuration.
                    '';
                  };

                  advertise.keepAlive = mkOption {
                    type = types.nullOr types.int;
                    default = null;
                    description = ''
                      The keep-alive interval remote peers use when communicating with
                      this interface. Noxa applies a non-null value to the host configuration.
                    '';
                  };

                  keepAlive = mkOption {
                    type = types.nullOr types.int;
                    default = null;
                    description = ''
                      The default keep-alive interval this interface uses when
                      communicating with remote peers. If the remote end sets
                      `advertise.keepAlive`, Noxa uses the smaller of the two values.
                      Noxa applies a non-null value to the host configuration.
                    '';
                  };

                  gatewayOverride = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = ''
                      If set, this interface uses the named host as the gateway for
                      this network instead of the automatically selected one.
                      Noxa applies a non-null value to the host configuration.
                    '';
                  };
                };

                config.advertise.server =
                  let
                    advertisedPublicIps = self.nixosConfigurations.${name}.config.noxa.wireguard.reachable.internet or [ ];
                  in
                  mkIf (length advertisedPublicIps > 0 && network.config.autoConfigureGateway) {
                    listenAddress = mkDefault (head advertisedPublicIps);
                    defaultGateway = mkDefault true;
                  };
              }));
              description = "Configuration of the WireGuard network's members.";
            };
          };
        }));
  };

  config.assertions =
    with noxaFlake.lib.ansi;
    lists.flatten (attrsets.mapAttrsToList
      (networkName: netConfig: map
        (nodeName: {
          assertion = elem nodeName config.noxa.managedNodes;
          message = "${fgYellow}Network ${fgCyan}'${networkName}'${fgYellow} declared a configuration for node ${fgCyan}'${nodeName}'${fgYellow}, but this node is not listed in ${fgGreen}noxa.managedNodes${fgYellow}.${default}";
        })
        (attrNames netConfig.members))
      config.noxa.wireguard);
}
