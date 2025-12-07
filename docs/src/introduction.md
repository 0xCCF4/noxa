# Intro

**Noxa** is a tool to ease the configuration of multi-host NixOS configurations.
Starting with the motivation, design goals, and design decisions, this handbook guides
you through setting up a multi-host NixOS configuration.

## Motivation

NixOS is a Linux distribution configuration solution composed of modules and packages [NixOS Manual](https://nixos.org/manual/nixos/stable/#preface). While [nixpkgs](https://github.com/NixOS/nixpkgs/) provides many modules for configuring NixOS machines, it lacks fundamental support for configuration beyond the scope of a single host.

In practice, some hosts share configuration settings. Imagine that you configure four different NixOS machines and would like to set up a WireGuard network between them. In the end, you will configure `networking.wireguard.interfaces.<name>` on each host, but there are several open questions:
1. Is specifying each network redundantly on each host necessary? Boiling it down: specifying a network (and members) once globally should be enough.
2. How do you manage secrets efficiently? Preshared connection keys, for example, are owned not by one but by two hosts. Should you specify them on several hosts redundantly, or would it be sufficient to declare the network topology globally?

This is were **noxa** shines. **Noxa** builds another layer on top of the "normal" per-system nixos configuration by providing inter host dependencies and configuration options.

## Goal

The goal of **Noxa** is to fill the gap of nixos-modules limited to only a single host, providing a framework to support the configuration of multiple hosts that:
1. Depend on each other
2. Depend on a global configuration that is not part of any specific host
3. Automates as many tasks that multi-host management requires (like exchanging secrets).

## How does it work

At the highest level, **Noxa** uses the same module system library to provide a global configuration environment. Settings specified here (in *noxa modules*) do not belong to the configuration of any specific host unless specified under `nodes.<name>.configuration`, which holds the configuration of host `<name>`.

For example, the following *Noxa module* declares two hosts, while `hostB` depends on the configuration values of `hostA`.
```nix
{config, ...}: {
    # Declaration of `hostA`
    nodes.hostA.configuration = {
        services.openssh.enable = true;

        /* Other NixOS configuration options */
    };

    # Declaration of `hostB`
    nodes.hostB.configuration = {
        imports = [
            ./some-nixos-module.nix
        ];

        # Access config values from other hosts
        networking.hostName =
            /* depend on configuration of hostA */
           "${config.nodes.hostA.configuration.networking.hostName}-copy";
    };

    imports = [
        ./some-other-noxa-module.nix
    ];

    /* Other Noxa configuration options */
}
```

> For a reference, which options are available to *noxa modules* checkout [Modules](./modules.md).

## Getting started

To quick start, initialize a new *noxa/nixos* project via:
```bash
nix flake init --template github:0xccf4/noxa
```

Compiling and deploying a new configuration, is done via the "normal" nixos
and build commands by:
```bash
nixos-rebuild switch --flake .#<hostname>
```

A more detailed guide is found in [Getting Started](./getting-started.md)

## Contributing

Contributions are welcome. Suggest new features and bugs via issues. Pull requests are welcome.


## Related projects

List of other multi-host configuration frameworks (feel free to add others):
- [nixus @infinisil (GPLv3)](https://github.com/infinisil/nixus/)

> Why another framework?
>
> Initially [@0xCCF4](https://github.com/0xCCF4/) started the project to learn Nix in-depth,
> but since it has grown to a usable multi-host configuration framework.
