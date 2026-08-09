# Intro

**Noxa** is a tool that eases the configuration of multi-host NixOS setups.
This handbook starts with the motivation and design, then guides you through
setting up a multi-host NixOS configuration.

## Motivation

NixOS configures a Linux distribution through modules and packages (see the
[NixOS Manual](https://nixos.org/manual/nixos/stable/#preface)).
[nixpkgs](https://github.com/NixOS/nixpkgs/) ships many modules for a single
host, but it has no built-in support for configuration that spans several
hosts.

In practice, hosts often share configuration. Say you configure four NixOS
machines and want a WireGuard overlay network between them. You could set
`networking.wireguard.interfaces.<name>` on each host, but two questions come
up:
1. Do you need to repeat the network definition on every host? Declaring a network (and its members) once, globally, should be enough.
2. How do you manage secrets? A pre-shared connection key belongs to two hosts, not one. Do you declare it redundantly on both hosts, or does declaring the network topology once suffice?

The overlay network itself is not part of any single host's configuration.
Only a host's *membership* in that network is a host-specific setting.

**Noxa** adds a layer on top of the per-host NixOS configuration for exactly
this: options and modules that span hosts, plus automation for the tasks that
come with running several hosts together (see the examples below).

## Goal

**Noxa** fills the gap nixpkgs leaves for multi-host configuration. It gives
you:
1. Modules where hosts depend on each other's configuration.
2. Options that describe a whole fleet, not any single host.
3. Automation for common multi-host tasks: secret exchange, overlay network setup, and cross-host SSH access.

## How it works

**Noxa** ships as a [flake-parts](https://flake.parts/) module. You import it
into your own flake, alongside [ez-configs](https://github.com/ehllie/ez-configs),
which discovers your hosts and builds each `nixosConfigurations.<name>` entry.
Noxa adds two things on top: `noxa.managedNodes`, an explicit list of which
hosts join the Noxa mesh, and `noxa.wireguard`, cross-host network topology
that does not belong to any single host. A host opts into Noxa's own NixOS
modules (wireguard, SSH, secrets) by importing them.

```nix
# flake.nix
{
  imports = [ inputs.ez-configs.flakeModule inputs.noxa.flakeModules.default ];

  ezConfigs.root = ./.;
  noxa.managedNodes = [ "hostA" "hostB" ];

  # A network that does not belong to any single host.
  noxa.wireguard.overlay-lan = {
    networkAddress = "10.0.0.0/24";
    members.hostA.deviceAddresses = "10.0.0.1/32";
    members.hostB.deviceAddresses = "10.0.0.2/32";
  };
}
```

```nix
# hosts/hostB.nix, discovered by ez-configs
{ config, self, ... }: {
  imports = [ inputs.noxa.nixosModules.wireguard ];

  # Read hostA's own config directly. self.nixosConfigurations is an
  # ordinary flake output, reachable from any host's own module.
  services.prometheus.scrapeConfigs = [{
    job_name = "node";
    targets = [ "hostA:${toString self.nixosConfigurations.hostA.config.services.prometheus.exporters.node.port}" ];
  }];
}
```

> For a reference of Noxa's own options, see [Modules](./modules.md).

## Getting started

To start, initialize a new *noxa/nixos* project:
```bash
nix flake init --template github:0xccf4/noxa
```

Compile and deploy a configuration with the standard NixOS commands:
```bash
nixos-rebuild switch --flake .#<hostname>
```

The [Getting Started](./getting-started.md) page walks through this in
detail.

## Contributing

Contributions are welcome. File issues for bugs or feature requests. Pull
requests are welcome too.

## Related projects

Other multi-host configuration frameworks (send a PR to add more):
- [nixus @infinisil (GPLv3)](https://github.com/infinisil/nixus/)

> Why another framework?
>
> [@0xCCF4](https://github.com/0xCCF4/) started the project to learn Nix in
> depth. It has since grown into a multi-host configuration framework used
> as a daily driver.
