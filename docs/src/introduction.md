# Intro

**Noxa** is a tool to ease the configuration of multi-host NixOS configurations.
Starting with the motivation, design goals, and design decisions, this handbook guides
you through setting up a multi-host NixOS configuration.

## Motivation

NixOS is a Linux distribution configuration solution composed of modules and packages [NixOS Manual](https://nixos.org/manual/nixos/stable/#preface). While [nixpkgs](https://github.com/NixOS/nixpkgs/) provides many modules for configuring NixOS machines, it lacks fundamental support for configuration beyond the scope of a single host.

In practice, some hosts share configuration settings. Imagine that you configure four different NixOS machines and would like to set up a WireGuard network between them. In the end, you will configure `networking.wireguard.interfaces.<name>` on each host, but there are several open questions:
1. Is specifying each network redundantly on each host necessary? Boiling it down: specifying a network once globally should be enough.
2. How do you manage secrets efficiently? Preshared connection keys, for example, are owned not by one but by two hosts. Should you specify them on several hosts redundantly, or would it be sufficient to declare the network topology globally?

To summarize, some configuration settings are shared among different hosts and do not belong to any specific one. For example, the existence of a WireGuard network and its configuration fundamentally does not belong to the configuration of a single NixOS host. Further, one host's configuration might depend on another's configuration.

Currently, [nixpkgs](https://github.com/NixOS/nixpkgs/) does not support these multi-host configuration scenarios and multi-host dependencies.

## Goal

The goal of **Noxa** is to fill this gap and provide a framework to support the configuration of multiple hosts that:
1. Potentially depend on each other
2. Depend on a global configuration

Whats contained in **Noxa**:
1. The module system scaffolding to set up a **noxa** configuration.
2. *Noxa modules* covering standard use-cases.
3. *Nixos modules* that configure the specified hosts according to the global configuration from *noxa modules*

## How does it work

At the highest level, **Noxa** uses the module system to provide a configuration environment. A *Noxa module* can extend the functionality of your configuration (like with standard NixOS modules).
The difference to the "normal" NixOS module system being the provided configuration options. Hosts are, for example, defined using the configuration value `nodes.<name>.***`. NixOS
configuration is then supplied via the `nodes.<name>.configuration` option.

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
           "${config.nodes.hostA.configuration.networking.hostName}-copy";
    };

    imports = [
        ./some-other-noxa-module.nix
    ];

    /* Other Noxa configuration options */
}
```

For a reference, which options are available to *noxa modules* checkout [options](./options.md).

## Contributing

Contributions are welcome. Suggest new features and bugs via issues. Pull requests are welcome.


## Related projects

Other frameworks already aim to implement multi-host NixOS configuration; the list is provided below.
Why another framework? Learning the Nix language and ecosystem.

List of other multi-host configuration frameworks (feel free to add others):
- [nixus @infinisil (GPLv3)](https://github.com/infinisil/nixus/)