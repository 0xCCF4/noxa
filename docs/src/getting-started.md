# Getting Started

## Quick start
Create a new *noxa* project:
```bash
nix flake init --template github:0xccf4/noxa
```

This sets up a template project structured as follows:
- `hardware` holds the `hardware-configuration.nix` files of your hosts.
- `hosts` holds the top-level configuration of each host. ez-configs discovers files here automatically.
- `nixos-modules` holds NixOS modules applied to every host.
- `modules/home` holds [home-manager](https://github.com/nix-community/home-manager/) modules.
- `modules/nixos` holds your own NixOS modules.
- `packages` holds custom derivations, available to your hosts through an overlay.
- `parts` holds [flake-parts](https://flake.parts/) modules that build up your `flake.nix`.
- `users` holds your user definitions, each with its own home-manager module.
- `secrets` holds the (encrypted) secrets for your hosts.

Change, restructure, and adapt the project freely. This is a starting point,
not a fixed layout. For more detail, see the template's
[README.md](https://github.com/0xCCF4/noxa/blob/main/examples/default/README.md).

## Setting up noxa
> Skip this step when you use the template project.

Noxa ships as a [flake-parts](https://flake.parts/) module, built on top of
[ez-configs](https://github.com/ehllie/ez-configs) for host discovery. Add
both to your `flake.nix`:

```nix
{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake parts, build flake outputs modularly
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Noxa
    noxa = {
      url = "github:0xCCF4/noxa";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
      inputs.agenix-rekey.follows = "agenix-rekey";
      inputs.home-manager.follows = "home-manager";
    };

    # Secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, noxa, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        noxa.flakeModules.default
        ./config.nix
      ];
    };
}
```

`config.nix` sets up ez-configs and Noxa's own options:
```nix
{ inputs, self, config, ... }: {
  # Use the flake's own store path. A `./.` path literal fails in
  # read-only evaluation, for example in `nix flake check`.
  ezConfigs.root = self.outPath;
  # ezConfigs.nixos.configurationsDirectory defaults to ./nixos-configurations;
  # override it to keep the `hosts` directory name from the template.
  ezConfigs.nixos.configurationsDirectory = "${config.ezConfigs.root}/hosts";

  ezConfigs.nixos.specialArgs = {
    inherit (inputs) agenix agenix-rekey home-manager;
  };
}
```

`noxa.flakeModules.default` brings in `ezConfigs.*` (host discovery and
defaults) and Noxa's own `noxa.managedNodes`/`noxa.wireguard` options. Every
host built by ez-configs also gets `self` and a `noxa` specialArg (carrying
`noxa.lib`, `noxa.managedNodes`, and `noxa.wireguard`) automatically. You do
not need to pass these yourself.

## Adding a new host
> When you use the template project, add a file under `hosts/`, named after
> your host, e.g. `vm-alice.nix`. It is the top-level configuration of that
> host, exactly like the `configuration.nix` of a plain NixOS setup. Since
> the file is new, `git add` it so Nix picks it up.

A host is a plain NixOS module discovered by ez-configs. To join the Noxa
mesh, list it in `noxa.managedNodes` (it defaults to every discovered host,
so most setups need no extra step) and import whichever Noxa modules the
host needs:

```nix
# hosts/hostA.nix
{ noxa, ... }: {
  ssh.enable = true;

  # Opt into Noxa's cross-host SSH module for this host
  imports = [ noxa.nixosModules.ssh ];
}
```

## Setting up secrets
*Noxa* uses [agenix](https://github.com/ryantm/agenix) and
[agenix-rekey](https://github.com/oddlama/agenix-rekey/) for secrets. To get
started, generate a master key and add each host's public SSH host key to
its configuration.

### Generating a master key
Generate a master key to encrypt secrets with:
```bash
mkdir -p $HOME/.noxa
nix shell "nixpkgs#age" -c age-keygen -o $HOME/.noxa/master.key
# note down the public key, you will need it below

# Recommended: encrypt the master key with a password
nix run "nixpkgs#age" -- --encrypt --armor --passphrase -o $HOME/.noxa/master.key.age $HOME/.noxa/master.key
rm $HOME/.noxa/master.key
```

### Adding a master key to the configuration
> When you use the template project, open `modules/nixos/secrets.nix` for
> placeholders to fill in with your generated master key.

A host needs `noxa.nixosModules.secrets` imported before it can use
`noxa.secrets.*`. Add an entry to `noxa.secrets.options.masterIdentities`
with the path and public key of your master key:
```nix
{ noxa, ... }: {
  imports = [ noxa.nixosModules.secrets ];

  noxa.secrets.options.masterIdentities = [
    {
      identity = "/home/user/.noxa/master.key.age";
      pubkey = "age1qql...";
    }
  ];
}
```

### Adding the public SSH host key of a host
Noxa stores secrets encrypted in the Nix store, so only the host they are
meant for can decrypt them, using its private SSH host key. Add the public
SSH host key of each host to its own configuration:
```nix
{ ... }: {
  # Inside the configuration of hostA
  noxa.secrets.options.hostPubkey = "ssh-ed25519 AAAAC...";
}
```

> When you use the template project, open `hosts/vm-bob.nix` for a
> placeholder to fill in with the public SSH host key of `vm-bob`.

### Further information about secrets
See the [Secrets module](./modules/secrets.md) documentation for more detail.

## Compiling and deploying a configuration
> When you use the template project, use the normal NixOS tools. Noxa's
> hosts already appear under the flake's `nixosConfigurations` attribute,
> e.g. `nixosConfigurations.vm-bob`, since that's what ez-configs builds.

Compile and deploy a configuration with the standard NixOS commands:
```bash
nixos-rebuild switch --flake .#<hostname>
```

# Further reading
Continue with the [Architecture](./architecture.md) page for how Noxa fits
together internally, or jump to a specific module in the
[Modules](./modules.md) section.
