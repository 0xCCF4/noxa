{ pkgs
, config
, lib
, noxa
, agenix
, agenix-rekey
, ...
}:
with lib; with builtins; with types;
let
  cfg = config.noxa.secrets;

  cleanPath = str: strings.replaceStrings [ "/" ":" ] [ "-" "" ] str;

  generatorType = {
    dependencies = mkOption {
      type =
        with types;
        oneOf [
          (listOf unspecified)
          (attrsOf unspecified)
        ];
      example = literalExpression ''[ config.age.secrets.basicAuthPw1 nixosConfigurations.machine2.config.age.secrets.basicAuthPw ]'';
      default = [ ];
      description = ''
        Other secrets on which this secret depends. See `agenix-rekey` documentation.
      '';
    };

    script = mkOption {
      type = either str (functionTo str);
      description = ''
        Generator script, see `agenix-rekey` documentation.
      '';
    };

    tags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "wireguard" ];
      description = ''
        Optional list of tags that may be used to refer to secrets that use this generator.
          
        See `agenix-rekey` documentation for more information.
      '';
    };
  };

  mock = additional: submodule (submod:
    let
      add = additional submod;
    in
    {
      options = (add.options or { }) // {
        hostSecret = mkOption {
          type = nullOr (submodule (submod: {
            options = {
              module = mkOption {
                type = str;
                description = ''
                  The owning module of that secret.

                  Typically this is the name of module declaring the secret, e.g. "noxa.wireguard.interfaces.<name>".
                '';
                example = "services.openssh";
              };
              name = mkOption {
                type = str;
                description = ''
                  The name of the secret.
                      
                  This is the name of the secret, e.g. "wg-interface-key".
                '';
                example = "wg-interface-key";
              };
            };
          }));
          default = null;
          description = ''
            A secret that is owned by a single host. To construct the path to the secret the following template ist
            used: `$\{noxa.secrets.hostSecretsPath}/$\{module}/$\{name}.age`.
          '';
          example = ''
            {
              module = "noxa.wireguard.interfaces.some-interface";
              name = "wg-interface-key";
            }
          '';
        };

        sharedSecret = mkOption {
          type = nullOr (submodule (submod: {
            options = {
              module = mkOption {
                type = str;
                description = ''
                  The owning module of that secret.

                  Typically this is the name of module declaring the secret, e.g. "noxa.wireguard.interfaces.<name>".
                '';
                example = "services.openssh";
              };
              name = mkOption {
                type = str;
                description = ''
                  The name of the secret.
                      
                  This is the name of the secret, e.g. "wg-interface-key".
                '';
                example = "wg-interface-key";
              };
              hosts = mkOption {
                type = listOf str;
                description = ''
                  The hosts that have access to this secret.
                '';
                example = [ "host1" "host2" ];
              };
            };
          }));
          default = null;
          description = ''
            A secret that is shared between several hosts. To construct the path to the secret
            the following template is used: `$\{noxa.secrets.sharedSecretsPath}/$\{hosts}/$\{module}/$\{name}.age`.

            Note that, all hosts that should have access to this secret must declare the secret in their
            nixos configuration. Since the secret path is derived from all hosts that have access to the secret,
            when changing that list, the secret path will change, hence the secret must be moved.
          '';
          example = ''
            {
              module = "noxa.wireguard.interfaces.some-interface";
              name = "wg-preshared-connection-key";
              hosts = [ "host1" "host2" ];
            }
          '';
        };

        identifier = mkOption {
          type = str;
          readOnly = true;
          description = ''
            A unique identifier for the secret, derived from the module and name.
            This may be used to name the secret.
          '';
        };
      };
      config =
        let
          module =
            if submod.config.hostSecret != null then
              cleanPath submod.config.hostSecret.module
            else if submod.config.sharedSecret != null then
              cleanPath submod.config.sharedSecret.module
            else
              null;

          hosts =
            if submod.config.sharedSecret != null then
              (concatStringsSep "," (lists.sort (a: b: a < b) submod.config.sharedSecret.hosts))
            else
              "";

          name =
            if submod.config.hostSecret != null then
              cleanPath submod.config.hostSecret.name
            else if submod.config.sharedSecret != null then
              cleanPath submod.config.sharedSecret.name
            else
              null;

          hostSecretRekeyFile = cfg.hostSecretsPath + "/${module}/${name}.age";
          sharedSecretRekeyFile = cfg.sharedSecretsPath + "/${module}/${hosts}/${name}.age";

          rekeyFile =
            if submod.config.hostSecret != null then
              hostSecretRekeyFile
            else if submod.config.sharedSecret != null then
              sharedSecretRekeyFile
            else
              null;

          prefix =
            if submod.config.hostSecret != null then
              "host"
            else if submod.config.sharedSecret != null then
              "shared"
            else
              null;

          identifier = "${prefix}:${module}:${hosts}:${name}";
        in
        (add.config or { }) // {
          rekeyFile = mkIf (rekeyFile != null) rekeyFile;
          identifier = mkIf (identifier != null) identifier;
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
              generator = generatorType;
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

          It is recommended to use `$\{config.networking.hostName}` to create a unique directory for each host.
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

  options.age.secrets = mkOption {
    type = attrsOf (mock (additional: { }));
  };

  imports = [
    agenix.nixosModules.default
    agenix-rekey.nixosModules.default
  ];

  config = {
    assertions = mkMerge (map
      (secret:
        [
          {
            assertion = secret.hostSecret == null || secret.sharedSecret == null;
            message = "At least one of `hostSecret` or `sharedSecret` must be set.";
          }
        ]
      )
      (attrValues config.age.secrets));

    noxa.secrets.hostSecretsPath = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/host"));
    noxa.secrets.sharedSecretsPath = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/shared"));
    noxa.secrets.options.rekeyDirectory = mkIf (cfg.secretsPath != null) (mkDefault (cfg.secretsPath + "/rekeyed/${config.networking.hostName}"));

    age.secrets = mkMerge (map
      (secret:
        {
          "${secret.identifier}" = {
            hostSecret = secret.hostSecret;
            sharedSecret = secret.sharedSecret;
            generator = mkIf (secret.generator != null) {
              script = mkIf (secret.generator.script != null) secret.generator.script;
              dependencies = mkIf (secret.generator.dependencies != null) secret.generator.dependencies;
              tags = mkIf (secret.generator.tags != null) secret.generator.tags;
            };
          };
        })
      cfg.def);

    age.generators.wireguard-key = { pkgs, file, ... }: ''
      mkdir -p $(dirname ${lib.escapeShellArg file})
      priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
      ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
      echo "$priv"
    '';

    age.generators.wireguard-psk = { pkgs, file, ... }: ''
      mkdir -p $(dirname ${lib.escapeShellArg file})
      ${pkgs.wireguard-tools}/bin/wg genpsk
    '';

    age.generators.dummy = { pkgs, file, ... }: ''
      mkdir -p $(dirname ${lib.escapeShellArg file})
      echo "This is a dummy secret, not meant to be used in production."
    '';

    age.rekey = mkIf (cfg.options.enable) {
      storageMode = mkDefault "local";
      localStorageDir = mkDefault cfg.options.rekeyDirectory;
      hostPubkey = mkIf (cfg.options.hostPubkey != null) (mkDefault cfg.options.hostPubkey);
      masterIdentities = mkDefault cfg.options.masterIdentities;
    };

    age.identityPaths = config.noxa.sshHostKeys.hostKeysPrivate;
  };
}
