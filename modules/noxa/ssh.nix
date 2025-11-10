{ lib, config, ... }: with lib; with builtins; {
  options.ssh = with types; {
    grant = mkOption {
      description = "Grant SSH access from from node users to to node users.";
      default = { };

      type = attrsOf (attrsOf (submodule {
        options.accessTo = mkOption {
          type = attrsOf (submodule {
            options.users = mkOption {
              type = listOf str;
              description = "List of users on the to node to grant access to.";
            };
          });
          description = "List of users on the to node to grant access to.";
        };
      }));
    };

    debug = mkOption {
      description = "Enable debug logging for the SSH module.";
      type = anything;
      readOnly = true;
    };
  };

  config =
    let
      traceX = s: trace ("[debug] " + toJSON s) s;
      grants = flatten (mapAttrsToList
        (fromNode: fromNodeValue:
          mapAttrsToList
            (fromUser: fromUserValue:
              mapAttrsToList
                (toNode: toNodeValue:
                  map
                    (toUser: {
                      from.node = fromNode;
                      from.user = fromUser;
                      to.node = toNode;
                      to.user = toUser;
                    }
                    )
                    toNodeValue.users
                )
                fromUserValue.accessTo
            )
            fromNodeValue
        )
        config.ssh.grant);
    in
    {

      ssh.debug = grants;
    };
}

