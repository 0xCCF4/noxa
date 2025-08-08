{ lib, noxa, options, config, ... }: with builtins; with lib; {
  options = with types; with noxa.lib.net.types; {
    wireguard = mkOption {
      description = ''

            '';
      default = { };
      type = attrsOf
        (submodule
          (network: {
            options = {
              networkAddress = mkOption {
                type = ipNetwork;
                description = ''
                  The network address of the wireguard network.
                '';
              };
              allowNodesToJoin = mkOption {
                type = bool;
                default = false;
                description = ''
                  If set to true, nodes may join this network by declaring `noxa.wireguard.interfaces.<interface>`.
                  If set to false, nodes may only join this network if declared in this network configuration.
                '';
              };
              autoConfigureGateway = mkOption {
                type = bool;
                default = true;
                description = ''
                  If set to true, the gateways for this network will be automatically configured based
                  on the `nodes.<name>.reachable.internet` attribute.
                '';
              };
              members = mkOption
                {
                  type = attrsOf (submodule ({ name, ... }: {
                    options = {
                      autostart = mkOption {
                        type = nullOr bool;
                        default = null;
                        description = ''
                          Specifies whether to autostart the WireGuard interface.

                          Only relevant if the `backend` is set to `wg-quick`.

                          If set to any other value than null, the value will be applied to the node configuration.
                        '';
                      };

                      backend = mkOption {
                        type = nullOr (enum [ "wireguard" "wg-quick" ]);
                        default = "wireguard";
                        description = ''
                          The backend to use for WireGuard config generation.
                          - `wireguard`: Uses the `networking.wireguard.interfaces` module to generate the configuration.
                          - `wg-quick`: Uses the `networking.wg-quick.interfaces` module to generate the configuration.

                          If set to any other value than null, the value will be applied to the node configuration.
                        '';
                      };

                      deviceAddresses = mkOption {
                        type = nullOr (coercedTo ip toList (listOf ip));
                        default = null;
                        description = ''
                          List of ip addresses to assign to this interface. The server will forward traffic
                          to these addresses.
                        '';
                      };

                      onlySpecifiedDeviceAddresses = mkOption {
                        type = bool;
                        default = true;
                        description = ''
                          If set to true, device addresses set by the node configuration are rejected.
                          If set to false, the node might add additional device addresses to the interface.
                        '';
                      };

                      advertise.server = mkOption {
                        type = nullOr (submodule (submod: {
                          options = {
                            listenPort = mkOption {
                              type = nullOr int;
                              default = null;
                              description = ''
                                The port this server will listen on for incoming connections.
                              '';
                            };

                            listenAddress = mkOption {
                              type = nullOr ip;
                              default = null;
                              description = ''
                                The address this server will listen on for incoming connections.
                              '';
                            };

                            defaultGateway = mkOption {
                              type = nullOr bool;
                              default = null;
                              description = ''
                                If set, this server will be the default gateway for clients.
                              '';
                            };

                            firewallAllow = mkOption {
                              type = nullOr bool;
                              default = null;
                              description = ''
                                If set, the nixos firewall will allow incoming connections to the advertised listen port.

                                If set to any other value than null, the value will be applied to the node configuration.
                              '';
                            };
                          };
                        }));
                        default = null;
                        description = ''
                          Options for wireguard servers. If a wireguard interface is regarded as a server (e.g. since it has a public IP address), it may advertise its service via the `server.advertise` option.

                          If set, all peers that would like to connect to that peer will use the advertised listen port and address as means of directly connecting to the server.

                          Further, if `server.defaultGateway` is set, all peers that do not advertise listen port and address will be reached via the server marked as default gateway. Therefore, only one interface may be marked as default gateway at any time.

                          If set to any other value than null, the value will be applied to the node configuration.
                        '';
                      };

                      advertise.keepAlive = mkOption {
                        type = nullOr int;
                        default = null;
                        description = ''
                          The keep alive interval remote peers should use when communicating with this interface.

                          If set to any other value than null, the value will be applied to the nodes configuration.
                        '';
                      };

                      keepAlive = mkOption {
                        type = nullOr int;
                        default = null;
                        description = ''
                          The default keep alive interval this interface will use when communicating with remote peers.

                          If the remote end uses `advertise.keepAlive`, the minimum value of both will be used.

                          If set to any other value than null, the value will be applied to the nodes configuration.
                        '';
                      };

                      gatewayOverride = mkOption {
                        type = nullOr str;
                        default = null;
                        description = ''
                          If set, this interface will use the specified node as the gateway for connecting to the wireguard network.

                          If set to any other value than null, the value will be applied to the nodes configuration.
                        '';
                      };
                    };

                    config = {
                      advertise.server =
                        let
                          advertisedPublicIps = config.nodes.${name}.reachable.internet or [ ];
                        in
                        mkIf (length advertisedPublicIps > 0 && network.config.autoConfigureGateway) {
                          listenAddress = mkDefault (head advertisedPublicIps);
                          defaultGateway = mkDefault true;
                        };
                    };
                  }));
                  description = ''
                    Configuration of the wireguard members.
                  '';
                };
            };
          }));
    };
  };

  config =
    let
      nodesContainedInConfig = lists.unique (lists.flatten (attrsets.mapAttrsToList (network: netConfig: attrNames netConfig.members) config.wireguard));

      lockedNetworksMembers = attrsets.mapAttrs (networkName: netConfig: attrNames netConfig.members) (attrsets.filterAttrs (networkName: netConfig: !netConfig.allowNodesToJoin) config.wireguard);
    in
    {
      nodes = mkMerge (map
        (nodeName:
          let
            networksNodeIsContainedIn = attrsets.filterAttrs (networkName: netConfig: elem nodeName (attrNames netConfig.members)) config.wireguard;
            setIfNotNull = value: mkIf (value != null) value;
            networksConfiguration = attrsets.mapAttrs
              (networkName: netConfig: {
                networkAddress = netConfig.networkAddress;
                autostart = setIfNotNull netConfig.members.${nodeName}.autostart;
                backend = setIfNotNull netConfig.members.${nodeName}.backend;
                deviceAddresses = setIfNotNull netConfig.members.${nodeName}.deviceAddresses;
                advertise.server = let server = netConfig.members.${nodeName}.advertise.server; in
                  mkIf (server != null) {
                    listenPort = setIfNotNull server.listenPort;
                    listenAddress = setIfNotNull server.listenAddress;
                    defaultGateway = setIfNotNull server.defaultGateway;
                    firewallAllow = setIfNotNull server.firewallAllow;
                  };
                advertise.keepAlive = setIfNotNull netConfig.members.${nodeName}.advertise.keepAlive;
                keepAlive = setIfNotNull netConfig.members.${nodeName}.keepAlive;
                gatewayOverride = setIfNotNull netConfig.members.${nodeName}.gatewayOverride;
              })
              networksNodeIsContainedIn;
          in
          {
            "${nodeName}".configuration.noxa.wireguard.interfaces = networksConfiguration;
          })
        nodesContainedInConfig);

      assertions = with noxa.lib.ansi; lists.flatten (
        (attrsets.mapAttrsToList
          (nodeName: node: map
            (networkName: [
              {
                assertion = (hasAttr networkName lockedNetworksMembers) -> (elem nodeName lockedNetworksMembers.${networkName});
                message = "${fgYellow}Node ${fgCyan}'${nodeName}'${fgYellow} is not allowed to join the locked network ${fgCyan}'${networkName}'${fgYellow}.${default}";
              }
              {
                assertion = (
                  (hasAttr networkName config.wireguard) &&
                  (hasAttr nodeName config.wireguard.${networkName}.members) &&
                  config.wireguard.${networkName}.members.${nodeName}.onlySpecifiedDeviceAddresses
                )
                ->
                (node.configuration.noxa.wireguard.interfaces.${networkName}.deviceAddresses ==
                config.wireguard.${networkName}.members.${nodeName}.deviceAddresses);
                message = "${fgYellow}Node ${fgCyan}'${nodeName}'${fgYellow} has device addresses set ${fgGreen+(toJSON (node.configuration.noxa.wireguard.interfaces.${networkName}.deviceAddresses or []))+fgYellow} for network ${fgCyan}'${networkName}'${fgYellow}, but the global network configuration requires that only the stated device addresses ${fgGreen+(toJSON (config.wireguard.${networkName}.members.${nodeName}.deviceAddresses or []))+fgYellow} are used.${default}";
              }
            ])
            (attrNames node.configuration.noxa.wireguard.interfaces))
          config.nodes)
        ++
        (attrsets.mapAttrsToList
          (networkName: netConfig: map
            (nodeName: {
              assertion = (hasAttr nodeName config.nodes) && (elem nodeName config.nodeNames);
              message = "${fgYellow}Network ${fgCyan}'${networkName}'${fgYellow} declared a configuration for node ${fgCyan}'${nodeName}'${fgYellow}, but this node does not exist in ${fgCyan}'nodes'${fgYellow}; or did you forget to add ${fgCyan}'${nodeName}'${fgYellow} to ${fgGreen}'nodeNames'${fgYellow}?.${default}";
            })
            (attrNames netConfig.members))
          config.wireguard)
      );
    };

}
