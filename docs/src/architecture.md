# Architecture

This page explains Noxa's internal concepts.

## Hosts

Noxa calls a machine it manages a "host". A host is a plain
`nixosConfigurations.<name>` entry, discovered and built by
[ez-configs](https://github.com/ehllie/ez-configs) from a file under your
`hosts` (or `nixos-configurations`) directory, the same directory layout
ez-configs itself uses. Noxa does not build hosts; it only adds options on
top of what ez-configs already builds.

### The managed-hosts list

`noxa.managedNodes` is an explicit list of host names that join the Noxa
mesh. It defaults to every host ez-configs discovers, so most setups never
set it directly. Narrow it to exclude a host that should stay outside the
mesh, for example an ISO installer configuration:

```nix
{
  noxa.managedNodes = [ "hostA" "hostB" ]; # excludes "iso"
}
```

Noxa's own modules (wireguard, SSH) use this list to validate cross-host
references and to iterate over every managed host without forcing evaluation
of each host's full configuration.

### Cross-host configuration

Since every host is an ordinary flake output, one host's module can read
another host's configuration directly through `self`:

```nix
# hosts/hostB.nix
{ self, ... }: {
  services.prometheus.scrapeConfigs = [{
    job_name = "node";
    targets = [ "hostA:${toString self.nixosConfigurations.hostA.config.services.prometheus.exporters.node.port}" ];
  }];
}
```

This works because Nix evaluates lazily: reading one field of
`self.nixosConfigurations.hostA` does not force the rest of it, so hostB's
own configuration can depend on hostA's without a cycle, as long as the
dependency does not loop back on itself.

### Cross-cutting configuration

Some settings belong to no single host: a WireGuard network's topology, for
example, spans every member host at once. Noxa's own options for this kind
of setting (`noxa.wireguard`) live in your flake-parts configuration, next
to `noxa.managedNodes` and `ezConfigs.*`, not inside any one host's file.

### Nixpkgs versions

Since ez-configs builds each host with a plain `nixpkgs.lib.nixosSystem`
call, a host uses whichever `nixpkgs` your own configuration passes it.
Noxa does not impose one. Different hosts can use different `nixpkgs`
versions the same way any multi-host flake-parts setup would: by building
each host's `nixosSystem` with the `nixpkgs` input you want for it.

## Module system

Noxa contributes options directly into your own flake-parts module tree. It
does not run a separate module evaluation of its own. Concretely,
`noxa.flakeModules.default` is a flake-parts module you import, exactly like
`ez-configs.flakeModule`. There is no equivalent of the old `noxa-instantiate`
step, and no separate special argument set for a "noxa-level" evaluation.

Every host, once built by ez-configs, receives:
- `self`: the flake's own output set, most importantly `self.nixosConfigurations`.
- `noxa`: the *noxa* flake itself, extended with `noxa.lib` (utility functions, including `noxa.lib.net`, vendored from `nix-net-lib`), `noxa.managedNodes`, and `noxa.wireguard`.
- `agenix`/`agenix-rekey`: only meaningful once a host imports `noxa.nixosModules.secrets`, but always present in specialArgs so that import works.

A host opts into Noxa's own NixOS modules by importing them. Module
inclusion is the only switch:
```nix
{
  imports = [
    inputs.noxa.nixosModules.wireguard
    inputs.noxa.nixosModules.ssh
    inputs.noxa.nixosModules.secrets
  ];
}
```
