## age\.rekey\.initialRollout

Indicates whether this is the initial rollout\. Secrets will not be available on the target host yet\.



*Type:*
boolean *(read only)*

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## age\.secrets



Extension of the ` age ` (agenix) secrets module to provide
secrets for multi-host NixOs configurations\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## age\.secrets\.\<name>\.hosts



The hosts that have access to this secret\.



*Type:*
unique list of string



*Default:*

```
[
  "<noxa-host-id>"
]
```



*Example:*

```
[
  "host1"
  "host2"
]
```

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## age\.secrets\.\<name>\.ident



The name of the secret\.

This is the name of the secret, e\.g\. “wg-interface-key”\.



*Type:*
string



*Example:*
` "wg-interface-key" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## age\.secrets\.\<name>\.identifier



A unique identifier for the secret, derived from the module and name\.
This may be used to name the secret\.



*Type:*
string *(read only)*



*Example:*
` "host:noxa.wireguard.interfaces.some-interface::wg-interface-key" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## age\.secrets\.\<name>\.module



The owning module of that secret\.

Typically this is the name of module declaring the secret, e\.g\. “noxa\.wireguard\.interfaces\.\<name>”\.



*Type:*
string



*Example:*
` "services.openssh" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.enable



Enables the secrets module, multi-host secret management\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def



A list of secrets that are managed by the noxa secrets module\.

Each secret is either a host specific secret or a shared secret\.
Host specific secrets are only available on the host that owns them, while shared secrets are available on all hosts that declare them\.

The options provided will be passed to the ` agenix ` module, by using the identifier as the name of the secret\.
The identifier is derived from the module and name of the secret, e\.g\.
“host:noxa\.wireguard\.interfaces\.some-interface::wg-interface-key” or “shared:noxa\.wireguard\.interfaces\.some-interface:host1,host2:wg-preshared-connection-key”\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.generator



The generator configuration for this secret\. See ` agenix-rekey ` documentation\.



*Type:*
null or (submodule)



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.generator\.dependencies



Other secrets on which this secret depends\. See ` agenix-rekey ` documentation\.



*Type:*
null or (list of unspecified value) or attribute set of unspecified value



*Default:*
` null `



*Example:*
` [ config.age.secrets.basicAuthPw1 nixosConfigurations.machine2.config.age.secrets.basicAuthPw ] `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.generator\.script



Generator script, see ` agenix-rekey ` documentation\.



*Type:*
null or string or function that evaluates to a(n) string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.generator\.tags



Optional list of tags that may be used to refer to secrets that use this generator\.

See ` agenix-rekey ` documentation for more information\.



*Type:*
null or (list of string)



*Default:*
` null `



*Example:*

```
[
  "wireguard"
]
```

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.group



The group to set on the secret file when it is created\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.hosts



The hosts that have access to this secret\.



*Type:*
unique list of string



*Default:*

```
[
  "<noxa-host-id>"
]
```



*Example:*

```
[
  "host1"
  "host2"
]
```

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.ident



The name of the secret\.

This is the name of the secret, e\.g\. “wg-interface-key”\.



*Type:*
string



*Example:*
` "wg-interface-key" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.identifier



A unique identifier for the secret, derived from the module and name\.
This may be used to name the secret\.



*Type:*
string *(read only)*



*Example:*
` "host:noxa.wireguard.interfaces.some-interface::wg-interface-key" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.mode



The file mode to set on the secret file when it is created\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.module



The owning module of that secret\.

Typically this is the name of module declaring the secret, e\.g\. “noxa\.wireguard\.interfaces\.\<name>”\.



*Type:*
string



*Example:*
` "services.openssh" `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.owner



The owner to set on the secret file when it is created\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.def\.\*\.rekeyFile



The path to the rekey file for this secret\. This is used by the ` agenix-rekey ` module to rekey the secret\.



*Type:*
absolute path *(read only)*

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.hostSecretsPath



The path where host secrets are stored\. This is the path where noxa will look for (encrypted) host specific secrets\.

This directory contains encrypted secrets for each host\.
Secrets in this directory are host specific, at least the secret part of the secret is owned by a single host
and only published to that host\.

An example secret would be the private wireguard key for an interface\. Still the public key might be
shared with other hosts\.

ATTENTION: Since this path is copied to the nix store, it must not contain any secrets that are not encrypted\.



*Type:*
absolute path

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.enable



Enables the ‘simple’ options, by providing settings proxy, a user can set the options, inside the ` noxa.secrets.options ` module
that will provide sensible defaults for the agenix and agenix-rekey module\.

If this is set to false, the user must set-up the agenix and agenix-rekey modules manually\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.hostPubkey



The public key of the host that is used to encrypt the secrets for this host\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.masterIdentities



A list of identities that are used to decrypt encrypted secrets for rekeying\.



*Type:*
list of (submodule)

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.masterIdentities\.\*\.identity



The identity that is used to encrypt and store secrets as \.age files\.
This must be an absolute path, given as string to not publish keys to the nix store\.

This is the private key file used\.



*Type:*
null or string

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.masterIdentities\.\*\.pubkey



The identity that is used to encrypt and store secrets as \.age files\.
This is the age public key of the identity, used to encrypt the secrets\.

This is the public key file used\.



*Type:*
null or string

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.options\.rekeyDirectory



The directory where the rekey files are stored\. This is used by the ` agenix-rekey ` module to rekey the secrets\.
This directory must be writable by the user that runs the ` agenix-rekey ` module and added to
the git repo\.

It is recommended to use ` $\{noxaHost} ` to create a unique directory for each host\.



*Type:*
absolute path

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.secretsPath



The path where all secrets are stored\. Subfolders are created for host specific and shared secrets\.



*Type:*
null or absolute path

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.secrets\.sharedSecretsPath



The path where secrets shared between several hosts are stored\. This is the path where noxa will look for (encrypted) shared secrets\.

This directory contains encrypted secrets that are shared between several hosts\.
Secrets in this directory are not host specific, they are not owned by a single host, but an group of hosts\.

An example secret would be the pre-shared symmetric key for a wireguard interface peer\.

Since this path is used by multiple hosts, it is recommended to set this path once for all hosts, instead of setting it per host\.

ATTENTION: Since this path is copied to the nix store, it must not contain any secrets that are not encrypted\.



*Type:*
absolute path

*Declared by:*
 - [noxa/modules/nixos/secrets/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/default.nix)



## noxa\.sshHostKeys\.generate



Generates SSH host keys on boot even if the openssh service is not enabled\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/secrets/sshHostKeys\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/sshHostKeys.nix)



## noxa\.sshHostKeys\.hostKeysPrivate



List of SSH private host keys, accessible during runtime\.



*Type:*
list of string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/secrets/sshHostKeys\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/sshHostKeys.nix)



## noxa\.sshHostKeys\.impermanencePathOverride



Override the storage location for the ssh keys\. Since some modules, like the ` noxa.secrets ` module,
depend on the keys being stored on a mounted disk during configuration activation, and not
expose functionality of systemd orderings, this option can be used to override the
storage location of the keys; useful when using impermanence setups\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/secrets/sshHostKeys\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/secrets/sshHostKeys.nix)


