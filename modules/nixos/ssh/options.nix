{ lib, noxaConfig, ... }: with lib; with builtins;
{
  options.ssh = with types; {
    grants = mkOption {
      description = "Grant SSH access from from node users to to node users.";
      default = { };

      type = attrsOf (submodule (submod: {
        options =
          let
            commandList = listOf (coercedTo package
              (value: {
                command = "${value}/bin/${value.meta.mainProgram}";
                aliases = [ value.meta.mainProgram ];
              })
              (submodule {
                options = {
                  command = mkOption {
                    description = "The command to allow.";
                    type = coercedTo package (value: "${value}/bin/${value.meta.mainProgram}") str;
                  };
                  aliases = mkOption {
                    description = "The SSH command that is requested by the user, mapping to this command.";
                    type = listOf str;
                    default = [ ];
                  };
                  passParameters = mkOption {
                    description = "Whether to pass any parameters given by the user to the command.";
                    type = bool;
                    default = false;
                  };
                };
              }));
          in
          {
            from = mkOption {
              description = "Source user name.";
              type = str;
            };
            to = mkOption {
              description = "Destination node and user.";
              defaultText = "<to>";
              type = submodule (submodInner: {
                options = {
                  node = mkOption {
                    description = "Destination node name.";
                    type = str;
                  };
                  user = mkOption {
                    description = "Destination user name.";
                    type = str;
                  };
                  sshFingerprint = mkOption {
                    description = "Expected SSH host key fingerprint of the destination node.";
                    type = nullOr str;
                    default = null;
                  };
                  hostname = mkOption {
                    description = ''
                      Hostname or IP address of the target node.
                      
                      Multiple addresses may be specified by providing a executable
                      each that when exiting with code 0 selects the corresponding address,
                      see the example value.
                    '';
                    type = either str (attrsOf (submodule {
                      options = {
                        priority = mkOption {
                          description = "Priority of this address option, lower values are preferred over higher ones.";
                          type = int;
                        };
                        command = mkOption {
                          description = "Command that when executed returns exit code 0 if this address should be used.";
                          type = coercedTo package (value: "${value}/bin/${value.meta.mainProgram}") str;
                          example = "ping -c 1 -W 1 192.168.0.55 > /dev/null";
                        };
                        host = mkOption {
                          description = "The hostname or IP address to use if this option is selected.";
                          type = str;
                          example = "192.168.0.55";
                        };
                        port = mkOption {
                          description = "SSH port of the target node for this address.";
                          type = int;
                          default = submodInner.config.port;
                          defaultText = "same as to.port";
                        };
                      };
                    }));
                    default = submod.config.to.node;
                    defaultText = "<to.node>";
                    example = {
                      local = {
                        priority = 10;
                        command = "ping -c 1 -W 1 192.168.0.55 > /dev/null";
                        host = "192.168.0.55";
                      };
                      public = {
                        priority = 20;
                        command = "true";
                        host = "host.example.com";
                      };
                    };
                  };
                  port = mkOption {
                    description = "SSH port of the target node.";
                    type = int;
                    default = 22;
                  };
                };
                config =
                  let
                    key = noxaConfig.nodes."${submodInner.config.node}".configuration.noxa.secrets.options.hostPubkey or null;
                  in
                  {
                    sshFingerprint = mkIf (key != null) key;
                  };
              });
            };
            name = mkOption {
              description = "Alias name under which the user can `ssh {alias}` to the target.";
              type = str;
              default = "${last submod._prefix}";
            };

            options = {
              restrict = mkOption {
                description = ''
                  Apply the "restrict" option to this SSH key, disabling every feature
                  except executing commands. Disabling this option, will circumvent all
                  other options set via .options .
                '';
                type = bool;
                default = true;
              };
              listen = mkOption {
                description = ''
                  Apply the "permitlisten" option to this SSH key, remote listening and
                  forwarding of ports to local ports.
                '';
                type = listOf str;
                default = [ ];
              };
              open = mkOption {
                description = ''
                  Apply the "permitopen" option to this SSH key, allowing to open
                  specific host:port combinations.
                '';
                type = listOf str;
                default = [ ];
              };
              pty = mkOption {
                description = ''
                  Apply the "pty" option to this SSH key, allowing to allocate a pseudo-terminal.
                '';
                type = bool;
                default = false;
              };
              x11Forwarding = mkOption {
                description = ''
                  Apply the "x11-forwarding" option to this SSH key, allowing X11 forwarding.
                '';
                type = bool;
                default = false;
              };
              agentForwarding = mkOption {
                description = ''
                  Apply the "agent-forwarding" option to this SSH key, allowing SSH agent forwarding.
                '';
                type = bool;
                default = false;
              };
            };

            extraConnectionOptions = mkOption {
              description = ''
                Additional SSH connection options to use when connecting to the target node.

                View man SSH(8) - AUTHORIZED_KEYS
              '';
              type = listOf str;
              default = [ ];
            };
            showAvailableCommands = mkOption {
              description = ''
                If set to true, when the user tries to execute an unauthorized command,
                the list of available commands will be shown.
              '';
              type = bool;
              default = true;
            };
            sshGenKeyType = mkOption {
              description = "When generating SSH keys use this key type.";
              type = enum [ "ed25519" "rsa" ];
              default = "ed25519";
            };
            commands = mkOption {
              description = ''
                Function that evaluates to a list of commands the user is allowed to execute on the target node. If empty, all commands are allowed.

                This function will be called with the pkgs.callPackage function taken from the target node.
              '';
              default = { ... }: [ ];
              type = functionTo commandList;
            };
            resolvedCommands = mkOption {
              description = "The resolved commands after evaluating the `commands` function.";
              type = either commandList str;
              readOnly = true;
            };
          };

        config = {
          extraConnectionOptions = [ ]
            ++ (optional submod.config.options.restrict "restrict")
            ++ (map (port: "permitlisten=\"${port}\"") submod.config.options.listen)
            ++ (map (open: "permitopen=\"${open}\"") submod.config.options.open)
            ++ (optional submod.config.options.pty "pty")
            ++ (optional submod.config.options.x11Forwarding "x11-forwarding")
            ++ (optional submod.config.options.agentForwarding "agent-forwarding");

          resolvedCommands =
            let
              # taken from lib.callPackageWith
              pkgs = noxaConfig.nodes."${submod.config.to.node}".pkgs;
              requiredArgs = submod.config.commands.__functionArgs;
              allArgs = intersectAttrs requiredArgs pkgs;
              missingArgs = filterAttrs (name: value: !value) (removeAttrs requiredArgs (attrNames allArgs));
              getSuggestions =
                arg:
                pipe (pkgs) [
                  attrNames
                  # Only use ones that are at most 2 edits away. While mork would work,
                  # levenshteinAtMost is only fast for 2 or less.
                  (filter (strings.levenshteinAtMost 2 arg))
                  # Put strings with shorter distance first
                  (sortOn (strings.levenshtein arg))
                  # Only take the first couple results
                  (take 3)
                  # Quote all entries
                  (map (x: "\"" + x + "\""))
                ];

              prettySuggestions =
                suggestions:
                if suggestions == [ ] then
                  ""
                else if length suggestions == 1 then
                  ", did you mean ${elemAt suggestions 0}?"
                else
                  ", did you mean ${concatStringsSep ", " (lib.init suggestions)} or ${lib.last suggestions}?";

              errorForArg =
                arg:
                let
                  loc = unsafeGetAttrPos arg requiredArgs;
                  loc' = if loc != null then loc.file + ":" + toString loc.line else "<unknown location>";
                in
                "Function called without required argument \"${arg}\" at "
                + "${loc'}${prettySuggestions (getSuggestions arg)}";

              # Only show the error for the first missing argument
              error = errorForArg (head (attrNames missingArgs));
            in
            if missingArgs == { } then submod.config.commands allArgs
            else with noxa.lib.ansi; "${fgYellow+bold}Error while evaluating ${noBold+italic}config.nodes.${fgCyan+name+fgYellow}.ssh.grants.${fgCyan + (last submod._prefix) + fgYellow}.commands${noItalic}: ${fgGreen}" + error + reset;
        };
      }));
    };
  };
} 
