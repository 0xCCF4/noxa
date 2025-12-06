{ lib, noxaConfig, noxaHost, noxa, ... }: with lib; {
  config = {
    users.users = mkMerge (
      flatten (
        map
          (
            (fromNodeName:
              let
                grants = noxaConfig.nodes."${fromNodeName}".configuration.ssh.grants;
                matching = filterAttrs (grantName: grant: grant.to.node == noxaHost) grants;
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
                    "${grant.to.user}".openssh.authorizedKeys.keys =
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
          )
          noxaConfig.nodeNames)
    );
  };
}
