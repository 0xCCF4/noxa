{ lib, config, noxaConfig, options, noxa, name, ... }: with lib; with builtins;
# todo: still missing assertion sanity checks
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
                    description = "Hostname or IP address of the target node.";
                    type = str;
                    default = submod.config.to.node;
                    defaultText = "<to.node>";
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

  config = {
    configuration = mkMerge
      (flatten ((mapAttrsToList
        (grantName: grant:
          let
            sshKeySecret = config.configuration.age.secrets.${noxa.lib.secrets.computeIdentifier {
              ident = "ssh-key-${grantName}";
              module = "noxa.ssh";
            }};
            pkgs = noxaConfig.nodes."${grant.to.node}".pkgs;
          in
          [{
            noxa.secrets.def = [
              {
                ident = "ssh-key-${grantName}";
                module = "noxa.ssh";
                generator.script = "ssh-keys-${grant.sshGenKeyType}";
                owner = grant.from;
              }
            ];
            home-manager.users."${grant.from}".programs.ssh.matchBlocks."${grantName}" =
              {
                host = grant.name;
                hostname = grant.to.hostname;
                port = grant.to.port;
                identitiesOnly = true;
                identityFile = sshKeySecret.path;
                user = grant.to.user;
                userKnownHostsFile =
                  if grant.to.sshFingerprint != null then
                    toString
                      (
                        pkgs.writeTextFile {
                          name = "known-hosts-${grant.name}";
                          text = "${grant.name} ${grant.to.sshFingerprint}\n";
                        }
                      )
                  else
                    "~/.ssh/known_hosts";
              };
            assertions = [
              {
                message = "${fgYellow}SSH grant config error: " + (if typeOf grant.resolvedCommands == "string" then grant.resolvedCommands else "invocation of function to resolve commands failed") + "${default}";
                assertion = typeOf grant.resolvedCommands == "list";
              }
            ];
          }])
        config.ssh.grants)
      ++
      flatten
        (map
          (fromNodeName:
            let
              grants = noxaConfig.nodes."${fromNodeName}".ssh.grants;
              matching = filterAttrs (grantName: grant: grant.to.node == name) grants;
              pkgs = noxaConfig.nodes."${fromNodeName}".pkgs;
            in
            mapAttrsToList
              (grantName: grant:
                let
                  sshKeySecret = noxaConfig.nodes."${fromNodeName}".configuration.age.secrets.${noxa.lib.secrets.computeIdentifier {
                    ident = "ssh-key-${grantName}";
                    module = "noxa.ssh";
                  }};
                  sshPubKeyFile = noxa.lib.filesystem.withExtension sshKeySecret.rekeyFile "pub";
                  sshPubKey = with noxa.lib.ansi; replaceStrings [ "\n" "\r" ] [ "" "" ] (noxa.lib.filesystem.readFileWithError sshPubKeyFile "${fgYellow}SSH public key file ${fgCyan}${toString sshPubKeyFile}${fgYellow} does not exist.\n       Did you run ${fgCyan}agenix generate${fgYellow} and ${fgCyan}git add${fgYellow}?${default}");
                in
                {
                  users.users."${grant.to.user}".openssh.authorizedKeys.keys =
                    let
                      resolvedCommands = grant.resolvedCommands;
                      execute = command:
                        if command.passParameters then ''
                          params=("''${CMD[@]:1}")
                          exec ${command.command} "''${params[@]}"
                        '' else ''
                          exec ${command.command}
                        '';
                      multipleCommands = commands: pkgs.writeShellApplication {
                        name = "ssh-command-wrapper";

                        text = ''
                          IFS=' ' read -r -a CMD <<< "''${SSH_ORIGINAL_COMMAND:-}"

                          case "''${CMD[0]:-}" in
                          ${concatMapStringsSep "\n" (command: let
                            aliasesPattern = if length command.aliases == 0 then
                              command.command
                            else
                              concatStringsSep "|" (map (alias: escapeShellArg alias) command.aliases);
                          in
                          "
                            ${aliasesPattern})
                                ${execute command}
                              ;;
                          ") resolvedCommands}
                            *)
                            ${pkgs.busybox}/bin/echo "Access denied."
                            ${if !grant.showAvailableCommands then "exit 1" else ''
                            ${pkgs.busybox}/bin/echo "Available commands are:"
                            ${concatMapStringsSep "\n" (command: let
                              aliasesList = if length command.aliases == 0 then
                                [ command.command ]
                              else
                                command.aliases;
                            in
                            concatMapStringsSep "\n  " (alias: "  echo  - \"${escapeShellArg alias}\"") aliasesList) resolvedCommands}
                            exit 1
                            ''}
                            ;;
                          esac
                          exit 1
                        '';
                      };
                      command =
                        if length resolvedCommands == 0 then
                          [ ]
                        else if length resolvedCommands == 1 then
                          [ "command=\"${escapeShellArg (head resolvedCommands).command}\"" ]
                        else
                          [ "command=\"${multipleCommands resolvedCommands}/bin/ssh-command-wrapper\"" ];
                      allOptions = concatStringsSep "," (grant.extraConnectionOptions ++ command);
                      allOptionsWithSpace = if allOptions == "" then "" else allOptions + " ";
                    in
                    [
                      "${allOptionsWithSpace}${sshPubKey}"
                    ];
                })
              matching
          )
          noxaConfig.nodeNames)
      ));
  };
}

