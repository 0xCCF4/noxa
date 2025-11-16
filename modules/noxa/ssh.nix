{ lib, config, options, noxa, ... }: with lib; with builtins; let
  traceX = s: trace ("[debug] " + toJSON s) s;
  traceAttrs = attrs: trace ("[debug] " + toJSON (attrNames attrs)) attrs;
in
{
  options.ssh = with types; {
    grants = mkOption {
      description = "Grant SSH access from from node users to to node users.";
      default = { };

      type = listOf (submodule (submod: {
        options = {
          from = mkOption {
            description = "Source node and user.";
            type = (submodule {
              options = {
                node = mkOption {
                  description = "Source node name.";
                  type = str;
                };
                user = mkOption {
                  description = "Source user name.";
                  type = str;
                };
              };
            });
          };
          to = mkOption {
            description = "Destination node and user.";
            type = (submodule {
              options = {
                node = mkOption {
                  description = "Destination node name.";
                  type = str;
                };
                user = mkOption {
                  description = "Destination user name.";
                  type = str;
                };
              };
            });
          };
          name = mkOption {
            description = "Alias name under which the user can `ssh {alias}` to the target.";
            type = str;
            default = "${submod.config.to.node}-${submod.config.to.user}";
          };
          hostname = mkOption {
            description = "Hostname or IP address of the target node.";
            type = str;
            default = submod.config.to.node;
          };
          port = mkOption {
            description = "SSH port of the target node.";
            type = int;
            default = 22;
          };
          connectionOptions = mkOption {
            description = ''
              Additional SSH connection options to use when connecting to the target node.

              View man SSH(8) - AUTHORIZED_KEYS
            '';
            type = listOf str;
            default = [ "restrict" ];
          };
          showAvailableCommands = mkOption {
            description = ''
              If set to true, when the user tries to execute an unauthorized command,
              the list of available commands will be shown.
            '';
            type = bool;
            default = true;
          };
          commands = mkOption {
            description = "List of commands the user is allowed to execute on the target node. If empty, all commands are allowed.";
            default = [ ];
            type = listOf (coercedTo package
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
          };
        };
      }));
    };

    sshKeyType = mkOption {
      description = "When generating SSH keys use this key type";
      type = enum [ "ed25519" "rsa" ];
      default = "ed25519";
    };

    computed = {
      grants = mkOption {
        description = "Computed set of SSH grants after merging duplicates.";
        type = options.ssh.grants.type;
        readOnly = true;
      };
    };

    debug = mkOption {
      description = "Enable debug logging for the SSH module.";
      type = anything;
      readOnly = true;
    };
  };

  config =
    let
      merge = definitions:
        let
          equal = a: b:
            a.from.node == b.from.node &&
            a.from.user == b.from.user &&
            a.to.node == b.to.node &&
            a.to.user == b.to.user &&
            a.name == b.name;

          grouped = foldl'
            (acc: def:
              let
                isEqual = map
                  (val: {
                    equal = equal def val;
                    val = val;
                  })
                  acc;
                matching = map (val: val.val) (filter (item: item.equal) isEqual);
                nonMatching = map (val: val.val) (filter (item: !item.equal) isEqual);

                match =
                  if length matching == 0 then
                    {
                      from.node = def.from.node;
                      from.user = def.from.user;
                      to.node = def.to.node;
                      to.user = def.to.user;
                      name = def.name;
                      values = [ ];
                    }
                  else
                    head matching;
              in
              nonMatching ++ [
                (match // {
                  values = match.values ++ [{ file = def.loc; value = removeAttrs def [ "loc" ]; }];
                })
              ]) [ ]
            definitions;
        in
        map (group: options.ssh.grants.type.nestedTypes.elemType.merge [ "ssh" "grants" ] group.values) grouped;

      grantDefinitionsWithLoc = map
        (entry: entry // {
          loc = "<unknown>";
        })
        config.ssh.grants;

      mergedGrants = merge grantDefinitionsWithLoc;


    in
    {
      ssh.computed.grants = mergedGrants;

      nodes = mkMerge (flatten (map
        (grant: let 
        sshPubKeyFile = noxa.lib.filesystem.withExtension config.nodes."${grant.from.node}".configuration.age.secrets.${noxa.lib.secrets.computeIdentifier {
                    ident = "ssh-key-${grant.from.node}-${grant.from.user}-to-${grant.to.node}-${grant.to.user}-alias-${grant.name}";
                    module = "noxa.ssh";
                  }}.rekeyFile "pub";
                  sshPubKey = with noxa.lib.ansi; replaceStrings [ "\n" "\r" ] [ "" "" ] (noxa.lib.filesystem.readFileWithError sshPubKeyFile "${fgYellow}SSH public key file ${fgCyan}${toString sshPubKeyFile}${fgYellow} does not exist.\n       Did you run ${fgCyan}agenix generate${fgYellow} and ${fgCyan}git add${fgYellow}?${default}");
                  pkgs = config.nodes."${grant.to.node}".pkgs;
        in [
          {
            "${grant.from.node}" = {
              configuration.noxa.secrets.def = [
                {
                  ident = "ssh-key-${grant.from.node}-${grant.from.user}-to-${grant.to.node}-${grant.to.user}-alias-${grant.name}";
                  module = "noxa.ssh";
                  generator.script = "ssh-keys-${config.ssh.sshKeyType}";
                  owner = grant.from.user;
                }
              ];
              configuration.home-manager.users."${grant.from.user}".programs.ssh.matchBlocks."${grant.name}" =
                {
                  host = grant.name;
                  hostname = grant.hostname;
                  port = grant.port;
                  identitiesOnly = true;
                  identityFile = config.nodes.${grant.from.node}.configuration.age.secrets.${noxa.lib.secrets.computeIdentifier {
                    ident = "ssh-key-${grant.from.node}-${grant.from.user}-to-${grant.to.node}-${grant.to.user}-alias-${grant.name}";
                    module = "noxa.ssh";
                  }}.path;
                  user = grant.to.user;
                  userKnownHostsFile = concatStringsSep " " [
                    (pkgs.writeTextFile {
                      name = "known-hosts-${grant.name}";
                      text = "${grant.name} ${sshPubKey}";
                    })
                    "~/.ssh/known_hosts"
                  ];
                };
            };
          }
          {
            "${grant.to.node}" = {
              configuration.users.users."${grant.to.user}".openssh.authorizedKeys.keys =
                let
                  captureParameters = capture:
                    if capture then ''
                      ${pkgs.busybox}/bin/read -r params
                    '' else ''
                      params=""
                    '';
                  multipleCommands = commands: config.nodes."${grant.to.node}".pkgs.writeShellApplication {
                    name = "ssh-command-wrapper";

                    text = ''
                      echo "TODO: REMOVE THIS DEBUG LINE: $SSH_ORIGINAL_COMMAND"

                      case "$SSH_ORIGINAL_COMMAND" in
                      ${concatMapStringsSep "\n" (command: let
                        aliasesPattern = if length command.aliases == 0 then
                          command.command
                        else
                          concatStringsSep "|" (map (alias: escapeShellArg alias) command.aliases);
                      in
                      "
                        ${aliasesPattern})
                            ${captureParameters command.passParameters}
                            # shellcheck disable=SC2086 # glob is ok on next line
                            exec ${command.command} \${params}
                          ;;
                      ") grant.commands}
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
                        concatMapStringsSep "\n  " (alias: "  echo  - \"${escapeShellArg alias}\"") aliasesList) grant.commands}
                        exit 1
                        ''}
                        ;;
                      esac
                      exit 1
                    '';
                  };
                  command =
                    if length grant.commands == 0 then
                      ""
                    else if length grant.commands == 1 then
                      "command=\"${escapeShellArg (head grant.commands).command}\""
                    else
                      "command=\"${multipleCommands grant.commands}/bin/ssh-command-wrapper\"";
                  allOptions = concatStringsSep "," (grant.connectionOptions ++ [ command ]);
                  allOptionsWithSpace = if allOptions == "" then "" else allOptions + " ";
                in
                [
                  "${allOptionsWithSpace}${sshPubKey}"
                ];
            };
          }
        ])
        config.ssh.computed.grants));

      ssh.debug = { };
    };
}

