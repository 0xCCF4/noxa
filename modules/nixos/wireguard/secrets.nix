{ pkgs
, config
, lib
, noxa
, nodes ? throw "Are you using this module outside of a Noxa configuration?"
, noxaHost ? throw "Are you using this module outside of a Noxa host configuration?"
, ...
}:
with lib; with builtins; with types;
let
  cfg = config.noxa.wireguard;
in
{
  options.noxa.wireguard = {
    secrets = mkOption {
      type = lazyAttrsOf (submodule (submod: {
        options = {
          publicKey = mkOption {
            type = str;
            readOnly = true;
            description = "The public key the wireguard interface";
          };

          privateKeyFile = mkOption {
            type = str;
            readOnly = true;
            description = "The private key file of the wireguard interface";
          };

          presharedKeyFiles = mkOption {
            type = lazyAttrsOf str;
            readOnly = true;
            description = "The pre-shared key file for each peer (by hostname) of the wireguard interface";
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

  config =
    let
      allmods = name: mapAttrs (key: value: value.noxa.wireguard.interfaces."${name}") (attrsets.filterAttrs (host: nixos: attrsets.hasAttrByPath [ "noxa" "wireguard" "interfaces" name ] nixos) nodes);
      exceptThis = attrsets.filterAttrs (host: nixos: host != noxaHost) allmods;
    in
    {
      noxa.secrets.def = mkMerge [
        (lists.flatten (map
          (name:
            let
              submod = cfg.interfaces.${name};
              datamod = cfg.routes.${name};
              uniqueVias = attrNames datamod.neighbors;
            in
            (map
              (target: {
                ident = "connection-psk-${name}";
                module = "noxa.wireguard";
                hosts = [ target noxaHost ];
                generator.script = "wireguard-psk";
              })
              uniqueVias) ++
            [{
              ident = "interface-key-${name}";
              module = "noxa.wireguard";
              generator.script = "wireguard-key";
            }]
          )
          (attrNames cfg.interfaces)))
      ];

      noxa.wireguard.secrets = mkMerge (map
        (name:
          let
            submod = cfg.interfaces.${name};
            datamod = cfg.routes.${name};
            uniqueTargets = attrNames datamod.neighbors;
          in
          {
            "${name}" =
              let
                keyFile = config.age.secrets.${noxa.lib.secrets.computeIdentifier {
                  module = "noxa.wireguard";
                  ident = "interface-key-${name}";
                }};
                publicKeyFile = noxa.lib.filesystem.withExtension keyFile.rekeyFile "pub";
              in
              {
                publicKey = with noxa.lib.ansi; if filesystem.pathIsRegularFile publicKeyFile then (replaceStrings [ "\n" ] [ "" ] (readFile publicKeyFile)) else throw "${fgYellow}WireGuard public key file ${fgCyan}${toString publicKeyFile}${fgYellow} does not exist.\n       Did you run ${fgCyan}agenix generate${fgYellow} and ${fgCyan}git add${fgYellow}?${default}";
                privateKeyFile = keyFile.path;
                presharedKeyFiles = mkMerge ((map
                  (target: {
                    "${target}" = config.age.secrets.${noxa.lib.secrets.computeIdentifier {
                      module = "noxa.wireguard";
                      hosts = [ target noxaHost ];
                      ident = "connection-psk-${name}";
                    }}.path;
                  })
                  uniqueTargets) ++ [{ }]);
              };
          })
        (attrNames cfg.interfaces));
    };
}
