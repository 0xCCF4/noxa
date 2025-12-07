# Intro

**Noxa** is a tool to ease the configuration of multi-host NixOS configurations.
Starting with the motivation, design goals, and design decisions, this handbook guides
you through setting up a multi-host NixOS configuration.

## Motivation

NixOS is a Linux distribution configuration solution composed of modules and packages
[NixOS Manual](https://nixos.org/manual/nixos/stable/#preface). While
[nixpkgs](https://github.com/NixOS/nixpkgs/) provides many modules for configuring NixOS
machines, it lacks fundamental support for configuration beyond the scope of a single host.

In practice, some hosts share configuration settings. Imagine that you configure four
different NixOS machines and would like to set up a WireGuard overlay network between them.
You will likely configure `networking.wireguard.interfaces.<name>` on each host,
but there are several open questions:
1. Is specifying each network redundantly on each host necessary? Boiling it down: specifying a network (and members) once globally should be enough, right?
2. How do you manage secrets efficiently? Preshared connection keys, for example, are owned not by one but by two hosts. Should you specify them on several hosts redundantly, or would it be sufficient to declare the network topology globally?

The problem we face here is, that the existance/declaration of the overlay network is conceptually
not part any host specific configuration. Instead only the membership to this network
might be a host specific setting.

**Noxa** builds another layer on top of the "normal"
per-system nixos configuration by providing inter host dependencies and configuration options; a higher-abtraction module system environment (see the Examples below).

## Goal

The goal of **Noxa** is to fill the gap of nixos-modules limited to only a single host,
providing a framework to support the configuration of multiple hosts that:
1. Depend on each other
2. Depend on a global configuration that is not part of any specific host
3. Automate as many tasks that multi-host management demands (like exchanging secrets, overlay network configuration, inter device SSH connection setup, ...).

## How does it work

At the highest level, **Noxa** uses the nixpkgs module system to declare global
settings and entities that do not belong to any specific host and the hosts itself.
Settings specified here (in *noxa modules*) do not belong to the configuration of
any specific host unless specified under `nodes.<name>.configuration`,
which holds the configuration of the host `<name>`.

For example, the following *Noxa module* declares two hosts, while `hostB`
depends on the configuration values of `hostA`.
```nix
{config, ...}: {
    # Declaration of `hostA`
    nodes.hostA.configuration = {
        # Add prometheus node exporter on non-default port
        services.prometheus.exporters.node = {
            enable = true;
            openFirewall = true;
            port = 6000;
        };

        /* Other NixOS configuration options */
    };

    # Declaration of `hostB`
    nodes.hostB.configuration = {
        # Import some nixos module for this host only
        imports = [
            ./some-nixos-module.nix
        ];

        # Configure prometheus collector
        services.prometheus = {
            enable = true;
            scrapeConfigs = [{
                job_name = "node";
                targets = [
                    # access config of `hostA`
                    "hostA:${config.nodes.hostA.configuration.services.prometheus.exporters.node.port}"
                ]
            }];
        };
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
build commands, e.g.:
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
> but since it has grown into a usable multi-host configuration framework that is used on a daily basis.
