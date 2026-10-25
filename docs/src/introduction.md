# Intro

**Noxa** is a harness and a set of NixOS modules that make cross-host
features easy in a multi-host NixOS setup. This handbook starts with the
motivation and design, then guides you through setting up a Noxa project.

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

Multi-host configuration itself is already possible without Noxa.
[ez-configs](https://github.com/ehllie/ez-configs) discovers and builds many
hosts from one flake, and one host can read another host's configuration
through `self.nixosConfigurations`. Noxa does not replace this. Noxa adds the
parts that ez-configs does not have: a harness for cross-host options and
modules that use it for common multi-host tasks.

## Goal

**Noxa** does not build hosts. ez-configs does that. Noxa gives you:
1. **The harness:** a flake-parts module that plugs into ez-configs. It adds
   the `noxa.managedNodes` list, options that describe a whole fleet (for
   example `noxa.wireguard`), and the `noxa` special argument (with
   `noxa.lib`) in every host.
2. **The modules:** NixOS modules that use the harness for common multi-host
   tasks: secret exchange (`secrets`), overlay networks (`wireguard`), and
   cross-host SSH access (`ssh`). A host imports only the modules it needs.

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
  # noxa.flakeModules.default also imports ez-configs.
  imports = [ inputs.noxa.flakeModules.default ];

  ezConfigs.root = self.outPath;
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
{ config, self, noxa, ... }: {
  imports = [ noxa.nixosModules.wireguard ];

  # Read hostA's own config directly. This is plain flake and ez-configs
  # behavior, not a Noxa feature: self.nixosConfigurations is an ordinary
  # flake output, reachable from any host's own module.
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

Other multi-host configuration projects (send a PR to add more):
- [nixus @infinisil (GPLv3)](https://github.com/infinisil/nixus/)

> Why another project?
>
> [@0xCCF4](https://github.com/0xCCF4/) started the project to learn Nix in
> depth. It has since grown into a harness and module set for multi-host
> NixOS setups, used as a daily driver.
