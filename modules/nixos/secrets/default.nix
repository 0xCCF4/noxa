/**
   Multi-host secrets management module
   This module is designated to facilitate easy multi-host
   key management.
   It is based on the `agenix` and `agenix-rekey` modules,
   augments them with additional options.

   The two main new concept is the differentiation between:
  1. Host specific secrets, which are secrets that are only
      available on a single host, e.g. the private key of a wireguard interface.
  2. Shared secrets, which are secrets that are shared between multiple hosts,
      e.g. the pre-shared symmetric key for a wireguard interface peer.
*/
{ pkgs
, config
, options
, lib
, noxa
, agenix
, agenix-rekey
, noxaHost ? throw "Are you using this module outside of a Noxa host configuration?"
, ...
}:
with lib; with builtins; with types;
let
  cfg = config.noxa.secrets;

  generatorType = {
    options = {
      dependencies = mkOption {
        type =
          nullOr (
            oneOf [
              (listOf unspecified)
              (attrsOf unspecified)
            ]);
        example = literalExpression ''[ config.age.secrets.basicAuthPw1 nixosConfigurations.machine2.config.age.secrets.basicAuthPw ]'';
        default = null;
        description = ''
          Other secrets on which this secret depends. See `agenix-rekey` documentation.
        '';
      };

      script = mkOption {
        type = nullOr (either str (functionTo str));
        default = null;
        description = ''
          Generator script, see `agenix-rekey` documentation.
        '';
      };

      tags = mkOption {
        type = nullOr (listOf str);
        default = null;
        example = [ "wireguard" ];
        description = ''
          Optional list of tags that may be used to refer to secrets that use this generator.
          
          See `agenix-rekey` documentation for more information.
        '';
      };
    };
  };

  mock = additional: submodule (submod:
    let
      add = additional submod;
    in
    {
      options = (add.options or { }) // {
        module = mkOption {
          type = str;
          description = ''
            The owning module of that secret.

            Typically this is the name of module declaring the secret, e.g. "noxa.wireguard.interfaces.<name>".
          '';
          example = "services.openssh";
        };
        ident = mkOption {
          type = str;
          description = ''
            The name of the secret.
                
            This is the name of the secret, e.g. "wg-interface-key".
          '';
          example = "wg-interface-key";
        };
        hosts = mkOption {
          type = noxa.lib.types.uniqueListOf str;
          description = ''
            The hosts that have access to this secret.
          '';
          example = [ "host1" "host2" ];
          default = [ noxaHost ];
        };
        identifier = mkOption {
          type = str;
          readOnly = true;
          example = "host:noxa.wireguard.interfaces.some-interface::wg-interface-key";
          description = ''
            A unique identifier for the secret, derived from the module and name.
            This may be used to name the secret.
          '';
        };
      };
      config =
        let
          hosts = noxa.lib.secrets.sortHosts (map noxa.lib.secrets.cleanIdentifier submod.config.hosts);
          ident = noxa.lib.secrets.cleanIdentifier submod.config.ident;
          module = noxa.lib.secrets.cleanIdentifier submod.config.module;

          hostPath = concatStringsSep "+" hosts;

          hostSecretRekeyFile = cfg.hostSecretsPath + "/${module}/${ident}.age";
          sharedSecretRekeyFile = cfg.sharedSecretsPath + "/${module}/${hostPath}/${ident}.age";

          rekeyFile =
            if length hosts <= 1 then
              hostSecretRekeyFile
            else
              sharedSecretRekeyFile;
        in
        (add.config or { }) // {
          rekeyFile = mkIf (rekeyFile != null) rekeyFile;
          identifier = noxa.lib.secrets.computeIdentifier {
            inherit module;
            inherit hosts;
            inherit ident;
          };
        };
    });
in
{
  options.noxa.secrets = {
    enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Enables the secrets module, multi-host secret management.
      '';
    };

    hostSecretsPath = mkOption {
      type = path;
      description = ''
        The path where host secrets are stored. This is the path where noxa will look for (encrypted) host specific secrets.
        
        This directory contains encrypted secrets for each host.
        Secrets in this directory are host specific, at least the secret part of the secret is owned by a single host
        and only published to that host.

        An example secret would be the private wireguard key for an interface. Still the public key might be
        shared with other hosts.

        ATTENTION: Since this path is copied to the nix store, it must not contain any secrets that are not encrypted.
      '';
    };

    sharedSecretsPath = mkOption {
      type = path;
      description = ''
        The path where secrets shared between several hosts are stored. This is the path where noxa will look for (encrypted) shared secrets.

        This directory contains encrypted secrets that are shared between several hosts.
        Secrets in this directory are not host specific, they are not owned by a single host, but an group of hosts.

        An example secret would be the pre-shared symmetric key for a wireguard interface peer.

        Since this path is used by multiple hosts, it is recommended to set this path once for all hosts, instead of setting it per host.

        ATTENTION: Since this path is copied to the nix store, it must not contain any secrets that are not encrypted.
      '';
    };

    secretsPath = mkOption {
      type = nullOr path;
      description = ''
        The path where all secrets are stored. Subfolders are created for host specific and shared secrets.
      '';
    };

    def = mkOption {
      type = listOf
        (mock
          (submod: {
            options = {
              rekeyFile = mkOption {
                type = path;
                readOnly = true;
                description = ''
                  The path to the rekey file for this secret. This is used by the `agenix-rekey` module to rekey the secret.
                '';
              };
              generator = mkOption {
                type = nullOr (submodule generatorType);
                default = null;
                description = ''
                  The generator configuration for this secret. See `agenix-rekey` documentation.
                '';
              };
            };
            default = [ ];
            description = ''
              A list of secrets that are managed by the noxa secrets module.

              Each secret is either a host specific secret or a shared secret.
              Host specific secrets are only available on the host that owns them, while shared secrets are available on all hosts that declare them.

              The options provided will be passed to the `agenix` module, by using the identifier as the name of the secret.
            '';
          }));
      default = [ ];
      description = ''
        A list of secrets that are managed by the noxa secrets module.

        Each secret is either a host specific secret or a shared secret.
        Host specific secrets are only available on the host that owns them, while shared secrets are available on all hosts that declare them.

        The options provided will be passed to the `agenix` module, by using the identifier as the name of the secret.
        The identifier is derived from the module and name of the secret, e.g.
        "host:noxa.wireguard.interfaces.some-interface::wg-interface-key" or "shared:noxa.wireguard.interfaces.some-interface:host1,host2:wg-preshared-connection-key".
      '';
    };
    options = {
      enable = mkOption {
        type = bool;
        default = true;
        description = ''
          Enables the 'simple' options, by providing settings proxy, a user can set the options, inside the `noxa.secrets.options` module
          that will provide sensible defaults for the agenix and agenix-rekey module.

          If this is set to false, the user must set-up the agenix and agenix-rekey modules manually.
        '';
      };
      rekeyDirectory = mkOption {
        type = path;
        description = ''
          The directory where the rekey files are stored. This is used by the `agenix-rekey` module to rekey the secrets.
          This directory must be writable by the user that runs the `agenix-rekey` module and added to
          the git repo.

          It is recommended to use `$\{noxaHost}` to create a unique directory for each host.
        '';
      };
      hostPubkey = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          The public key of the host that is used to encrypt the secrets for this host.
        '';
      };
      masterIdentities = mkOption {
        type = listOf (submodule (submod: {
          options = {
            identity = mkOption {
              type = nullOr str;
              description = ''
                The identity that is used to encrypt and store secrets as .age files.
                This must be an absolute path, given as string to not publish keys to the nix store.

                This is the private key file used.
              '';
            };
            pubkey = mkOption {
              type = nullOr str;
              description = ''
                The identity that is used to encrypt and store secrets as .age files.
                This is the age public key of the identity, used to encrypt the secrets.

                This is the public key file used.
              '';
            };
          };
        }));
        description = ''
          A list of identities that are used to decrypt encrypted secrets for rekeying.
        '';
      };
    };
  };

  options.age.rekey.initialRollout = mkOption {
    type = bool;
    default = options.age.rekey.hostPubkey.default == config.age.rekey.hostPubkey;
    readOnly = true;
    description = ''
      Indicates whether this is the initial rollout. Secrets will not be available on the target host yet.
    '';
  };

  options.age.secrets = mkOption
    {
      type = attrsOf (mock (additional: { }));
    } // (if agenix.nixosModules.default == { } then {
    # for building the documentation
    description = ''
      Extension of the `age` (agenix) secrets module to provide
      secrets for multi-host NixOs configurations.
    '';
  } else { });

  imports = [
    agenix.nixosModules.default
    agenix-rekey.nixosModules.default
    ./sshHostKeys.nix
    ./generators.nix
  ];

  config = {
    assertions = with noxa.lib.ansi; [
      {
        assertion = length (attrNames config.age.secrets) > 0 -> (config.age.rekey.storageMode == "local" -> filesystem.pathIsDirectory config.age.rekey.localStorageDir);
        message = "${bold+fgRed}The local storage directory for rekeying secrets ${fgCyan}'${toString config.age.rekey.localStorageDir}'${fgRed} does not exist. Did you run ${noBold}${fgCyan}'agenix rekey'${default}${bold}${fgRed} to create it?${default}";
      }
    ]
    ++
    (map
      (secret:
        {
          assertion = length secret.hosts <= 1 -> elem noxaHost secret.hosts;
          message = "${fgYellow}Defined secret ${fgCyan}'${secret.identifier}'${fgYellow} is not defined on the host that owns it: ${fgCyan}'${noxaHost}'${fgYellow}, instead it is defined on: ${fgCyan}'${head secret.hosts}Ä${default}";
        })
      cfg.def)
    ;

    warnings = with noxa.lib.ansi; (map
      (secret: mkIf (!(elem noxaHost secret.hosts))
        "${fgYellow}Defined secret ${fgCyan}'${secret.identifier}'${fgYellow} is not shared to the host on which it is defined: ${fgCyan}'${noxaHost}'${fgYellow}, instead it is shared to: ${fgCyan}${toJSON secret.hosts}${default}"
      )
      cfg.def);

    noxa.secrets.hostSecretsPath = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/host/${noxaHost}"));
    noxa.secrets.sharedSecretsPath = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/shared"));
    noxa.secrets.options.rekeyDirectory = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/rekeyed/${noxaHost}"));

    age.secrets = mkMerge (map
      (secret:
        {
          "${secret.identifier}" = {
            inherit (secret) module ident hosts;
            generator = mkIf (secret.generator != null) {
              script = mkIf (secret.generator.script != null) secret.generator.script;
              dependencies = mkIf (secret.generator.dependencies != null) secret.generator.dependencies;
              tags = mkIf (secret.generator.tags != null) secret.generator.tags;
            };
          };
        })
      cfg.def);

    age.rekey = mkIf (cfg.options.enable) {
      storageMode = mkDefault "local";
      localStorageDir = mkDefault cfg.options.rekeyDirectory;
      hostPubkey = mkIf (cfg.options.hostPubkey != null) (mkDefault cfg.options.hostPubkey);
      masterIdentities = mkDefault cfg.options.masterIdentities;
    };

    age.identityPaths = config.noxa.sshHostKeys.hostKeysPrivate;
  };
}
