# Getting Started

## Quick start
Create a new *noxa* project via:
```bash
nix flake init --template github:0xccf4/noxa
```

Which will set you up with a basic template project structured as follows:
- `hardware` contains the `hardware-configuration.nix` files of your hosts.
- `hosts` contains the toplevel definitions of your machines/hosts
- `modules/home` contains [home-manager](https://github.com/nix-community/home-manager/) modules
- `modules/nixos` contains nixos modules
- `modules/noxa` contains noxa modules
- `packages` contains custom nix derivation which will be available to your hosts
- `parts` contains [flake-parts](https://flake.parts/) modules to build up your flake.nix
- `users` contains the definition of your users, with their respective home-manager modules
- `secrets` will contain the secrets of your hosts

Of course feel free to change, restructure and adapt the project to your needs. The above is just a template to get you started fast. For additional information see also the [README.md](https://github.com/0xCCF4/noxa/blob/main/examples/default/README.md) of the template.

## Setting up noxa
> When using the template project, skip this step.

To add *noxa* to your flake, 1. add it as an input to your `flake.nix`, then, 2. instantiate it via `noxa.lib.noxa-instantiate`.

Below you will find an example `flake.nix`:
```nix
{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

  outputs =
    { self
    , nixpkgs
    , agenix
    , agenix-rekey
    , noxa
    , home-manager
    , ...
    }:
      with nixpkgs.lib; with builtins;
      {
        # Noxa configuration
        noxaConfiguration = noxa.lib.noxa-instantiate {
          modules = [ ./config.nix ];
          specialArgs = {
            inherit agenix;
            inherit agenix-rekey;
            inherit home-manager;
          };
        };
      };
}
```

The function `noxa.lib.noxa-instantiate` will instantiate your configuration and accepts as arguments:
- `modules`: A list of *noxa modules* which will be used to build up your configuration. In here, you will add your hosts and other configuration options.
- `specialArgs`: A set of arguments which will be passed to all *noxa modules*

*Noxa* uses the same module system as nixos and home-manager, so all concept of options, modules, etc. apply to *noxa modules* as well.

## Adding a new host
> When using the template project, navigate to `hosts/`, just add a new file with the name of your host, e.g. `vm-alice.nix` and add the configuration of your host there. This file will the the toplevel declaration of your host, like the normal `configuration.nix` file of a nixos configuration. (To let nix know about the new file, you will have to `git add` it.)

Adding a host can be done via declaring it inside a *noxa module*, e.g.:
```nix
{...}: {
  nodes.hostA = {
    # Host specific configuration options, e.g.:
    configuration = {
      # Add prometheus node exporter on non-default port
      services.ssh.enable = true;

      /* Other NixOS configuration options */
    };
  };

  nodeNames = [ "hostA" ];
}
```

## Setting up secrets
*Noxa* uses by default [agenix](https://github.com/ryantm/agenix) and [agenix-rekey](https://github.com/oddlama/agenix-rekey/) to manage secrets. To get started using secrets, you will need to generate a master key and include the public SSH host keys of your hosts in their hosts configuration.

### Generating a master key
Generate a master key to encrypt secrets with.
```bash
mkdir -p $HOME/.noxa
nix shell "nixpkgs#age" -c age-keygen -o $HOME/.noxa/master.key
# note down the public key, you will need it below

# Recommended: Encrypt the master key with a password
nix run "nixpkgs#age" -- --encrypt --armor --passphrase -o $HOME/.noxa/master.key.age $HOME/.noxa/master.key
rm $HOME/.noxa/master.key
```

### Adding a master key to the configuration
> When using the template project, navigate to `modules/nixos/secrets.nix`, you will find placeholders to add your previously generated master key to the configuration.

Create a entry in `noxa.secrets.options.masterIdentities` with the path and public key of your master key, e.g.:
```nix
noxa.secrets.options.masterIdentities = [
  {
    identity = "/home/user/.noxa/master.key.age";
    pubkey = "age1qql...";
  }
];
```

### Adding a new host or adding the public SSH host to the configuration
Secrets will be stored encrypted in the nix store, such that only the host they are meant for can decrypt them using
their private SSH host key. Therefore, you will have to add the public SSH host key of your hosts to the respective host configuration, e.g.:
```nix
{...}: {
  # Inside host configuration of `hostA`
  config = {
    # Add the public SSH host key of `hostA` to the configuration
    noxa.secrets.options.hostPubkey = "ssh-ed25519 AAAAC...";
  };
}

> When using the template project, navigate to `hosts/vm-bob.nix`, you will find a placeholder to add the public SSH host key of `vm-bob` to the configuration.
```

### Further information about secrets
Further information about secrets and how to use them can be found in the [Secrets module](./modules/secrets.md) documentation.

## Compiling and deploying a configuration
> When using the template project, you may use any tool to build and deploy the configuration since *noxa*'s output will be available via the `nixosConfigurations` attribute of the flake, e.g. `nixosConfigurations.vm-bob`.

Compiling and deploying a new configuration, is done via the "normal" nixos
and build commands by:
```bash
nixos-rebuild switch --flake .#<hostname>
```

When you are not using the template project, you might want to add compatibility for the these tools, by, e.g. adding
the following to your `flake.nix` `outputs` section:
```nix
# NixOS tool compatibility
nixosConfigurations = mapAttrs
  (name: value: {
    config = value.configuration;
    options = value.options;
  })
  self.noxaConfiguration.config.nodes;
```

# Further reading
You may continue reading on the architecture and instantiation of the module system in the [Architecture](./architecture.md) or jump to the explanation of a specific module in the [Modules](./modules.md) section.