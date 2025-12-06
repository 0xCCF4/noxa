{ config, lib, home-manager, noxa, pkgs, ... }: with lib; {
  noxa.secrets.def = mapAttrsToList
    (grantName: grant:
      {
        ident = "ssh-key-${grantName}";
        module = "noxa.ssh";
        generator.script = "ssh-keys-${grant.sshGenKeyType}";
        owner = grant.from;
      })
    config.ssh.grants;

  home-manager.users = mkMerge (flatten (
    (
      mapAttrsToList
        (grantName: grant:
          let
            sshKeySecret = config.age.secrets.${noxa.lib.secrets.computeIdentifier {
              ident = "ssh-key-${grantName}";
              module = "noxa.ssh";
            }};
            hostNameAttrs = if typeOf grant.to.hostname == "string" then { } else grant.to.hostname;

            traceX = s: builtins.trace (builtins.toJSON s) s;

            block = extra: {
              identitiesOnly = true;
              identityFile = sshKeySecret.path;
              user = grant.to.user;
              userKnownHostsFile =
                if grant.to.sshFingerprint != null then
                  toString
                    (
                      pkgs.writeTextFile {
                        name = "known-hosts-${grant.name}";
                        text = concatStringsSep "\n" (
                          map (name: "${name} ${grant.to.sshFingerprint}") (if typeOf grant.to.hostname == "string" then
                            [ grant.to.hostname ] else (mapAttrsToList (name: value: value.host) hostNameAttrs)));
                      }
                    )
                else
                  "~/.ssh/known_hosts";
            };
          in
          [{
            "${grant.from}".programs.ssh.matchBlocks."${grantName}" = mkIf (typeOf grant.to.hostname == "string") (
              mkMerge [
                block
                {
                  hostname = grant.to.hostname;
                  port = grant.to.port;
                  host = grant.name;
                }
              ]
            );
          }] ++ (mapAttrsToList
            (ruleName: rule:
              let
                rulesWithLowerPriority =
                  filterAttrs
                    (otherName: otherRule:
                      (otherName != ruleName)
                      && (otherRule.priority < rule.priority)
                    )
                    hostNameAttrs;
              in
              {
                "${grant.from}".programs.ssh.matchBlocks."${grantName}-${ruleName}" = home-manager.lib.hm.dag.entryAfter (mapAttrsToList (ruleName: rule: "${grantName}-${ruleName}") rulesWithLowerPriority) (
                  mkMerge [
                    block
                    {
                      match = "host=\"${escapeShellArg (grant.name)}\" exec=\"${pkgs.writeShellApplication {
                        name = "connect-check";
                        text = "exec ${rule.command}";
                      }}/bin/connect-check\"";
                      hostname = rule.host;
                      port = rule.port;
                    }
                  ]
                );
              })
            hostNameAttrs
          )
        )
        config.ssh.grants
    )
  ));


  assertions = mapAttrsToList
    (grantName: grant:
      {
        message = "${lib.ansi.fgYellow}SSH grant config error for grant ${lib.ansi.fgCyan}${name}.${grantName}${lib.ansi.fgYellow}: " + (if typeOf grant.resolvedCommands == "string" then grant.resolvedCommands else "invocation of function to resolve commands failed") + "${lib.ansi.default}";
        assertion = typeOf grant.resolvedCommands == "list";
      })
    config.ssh.grants;
}
