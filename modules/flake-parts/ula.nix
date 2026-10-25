/**
  Fleet-wide IPv6 unique local address (ULA) prefix.

  Noxa derives one /64 per WireGuard network and one /128 per member from
  this prefix (see `modules/flake-parts/wireguard.nix`). Hosts receive the
  same settings through the `noxa.ula` specialArg, so they can carve their
  own subnets (e.g. for containers) out of the same prefix.
*/
{ config, lib, nixNetLib, noxaFlake, ... }: with lib; with builtins; let
  cfg = config.noxa.ula;
in
{
  options.noxa.ula = with nixNetLib.types; {
    prefix = mkOption {
      type = types.nullOr ipNetwork;
      default = null;
      example = "fd12:3456:789a::/48";
      description = ''
        The ULA prefix, a random /48 out of `fd00::/8` (RFC 4193), e.g. generated with
        `h=$(openssl rand -hex 5); echo "fd''${h:0:2}:''${h:2:4}:''${h:6:4}::/48"`.
        If null, Noxa assigns no IPv6 addresses.
      '';
    };

    salt = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Secret salt mixed into every derived subnet and address, so they can not be
        recomputed from the public configuration alone, e.g. `openssl rand -hex 32`.
      '';
    };

    subnets = mkOption {
      type = types.attrsOf ipNetwork;
      default = { };
      description = ''
        Registry of subnets carved out of `prefix`, keyed by an arbitrary name.
        Noxa registers every WireGuard network as `wireguard-<name>`. Noxa asserts
        that no two entries are equal.
      '';
    };

    subnetFor = mkOption {
      type = types.functionTo ipNetwork;
      readOnly = true;
      default = name: nixNetLib.hashedIpv6Subnet {
        inherit (cfg) salt;
        network = cfg.prefix;
        inherit name;
        prefixLength = 64;
      };
      defaultText = literalExpression "name: <hashed /64 out of prefix>";
      description = "Derives the /64 for `name` out of `prefix`.";
    };

    addressFor = mkOption {
      type = types.functionTo (types.functionTo types.str);
      readOnly = true;
      default = network: name: nixNetLib.hashedIpv6Address {
        inherit (cfg) salt;
        inherit network name;
      };
      defaultText = literalExpression "network: name: <hashed address in network>";
      description = "Derives the address of `name` inside `network` (a /64).";
    };
  };

  config.assertions = with noxaFlake.lib.ansi;
    [
      {
        assertion = cfg.prefix != null -> cfg.salt != null;
        message = "${fgYellow}${fgCyan}noxa.ula.salt${fgYellow} must be set when ${fgCyan}noxa.ula.prefix${fgYellow} is set.${default}";
      }
    ]
    ++ (
      let
        byValue = groupBy (name: cfg.subnets.${name}) (attrNames cfg.subnets);
      in
      mapAttrsToList
        (subnet: names: {
          assertion = length names == 1;
          message = "${fgYellow}The ULA subnets ${fgCyan}${concatStringsSep ", " names}${fgYellow} collide on ${fgGreen}${subnet}${fgYellow}. Rename one of them or change ${fgCyan}noxa.ula.salt${fgYellow}.${default}";
        })
        byValue
    );
}
