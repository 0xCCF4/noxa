/**
   Module to ensure the generation of SSH host keys,
   even if the openssh service is not enabled.

   Since by default, our secrets module uses the SSH host keys
   for secret decryption at runtime, this module ensures that
  the keys are generated and available at runtime even
  for hosts without the openssh service enabled.
  */
{ pkgs
, lib
, config
, ...
}: with lib; with builtins; with types;
let
  cfg = config.noxa.sshHostKeys;
  cfgOpenssh = config.services.openssh or { };
in
{
  options.noxa.sshHostKeys = {
    generate = mkOption {
      type = bool;
      default = !cfgOpenssh.enable or true;
      description = ''
        Generates SSH host keys on boot even if the openssh service is not enabled.
      '';
    };

    hostKeysPrivate = mkOption {
      type = listOf str;
      description = ''
        List of SSH private host keys, accessible during runtime.
      '';
      readOnly = true;
    };

    impermanencePathOverride = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Override the storage location for the ssh keys. Since some modules, like the `noxa.secrets` module,
        depend on the keys being stored on a mounted disk during configuration activation, and not
        expose functionality of systemd orderings, this option can be used to override the
        storage location of the keys; useful when using impermanence setups.
      '';
    };
  };

  config =
    let
      resolvePath = path:
        if cfg.impermanencePathOverride != null
        then cfg.impermanencePathOverride
        else path;
    in
    {
      noxa.sshHostKeys.hostKeysPrivate = map (key: resolvePath key.path) cfgOpenssh.hostKeys;

      systemd.services.genHostKeys = mkIf (cfg.generate) {
        description = "Generate SSH Host Keys";
        wantedBy = [ "local-fs.target" ];
        before = [ "sshd.service" ];
        after = [ "local-fs.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          # Make sure we don't write to stdout, since in case of
          # socket activation, it goes to the remote side (#19589).
          exec >&2

          ${flip concatMapStrings cfgOpenssh.hostKeys (k: ''
            if ! [ -s "${resolvePath k.path}" ]; then
                if ! [ -h "${resolvePath k.path}" ]; then
                    rm -f "${resolvePath k.path}"
                fi
                mkdir -m 0755 -p "$(dirname '${k.path}')"
                ${pkgs.openssh}/bin/ssh-keygen \
                  -t "${k.type}" \
                  ${optionalString (k ? bits) "-b ${toString k.bits}"} \
                  ${optionalString (k ? rounds) "-a ${toString k.rounds}"} \
                  ${optionalString (k ? comment) "-C '${k.comment}'"} \
                  ${optionalString (k ? openSSHFormat && k.openSSHFormat) "-o"} \
                  -f "${resolvePath k.path}" \
                  -N ""
            fi
          '')}
        '';
      };
    };
}
