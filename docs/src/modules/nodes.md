# Hosts

Noxa does not define hosts itself. [ez-configs](https://github.com/ehllie/ez-configs)
discovers each host from a file (or directory) under `ezConfigs.nixos.configurationsDirectory`
and builds it with a plain `nixpkgs.lib.nixosSystem` call. Noxa adds
`noxa.managedNodes` on top, to say which of those hosts join the Noxa mesh.

## Defining a host

Add a file to the configured hosts directory (`./hosts` in the template).
The file name becomes the host name, and its content is a plain NixOS
module, the same shape as any `configuration.nix`:

```nix
# hosts/my-node.nix
{ ... }: {
  # (NixOS) configuration of the host "my-node"
  # ...
}
```

> When you use the template, new files under `hosts/` are picked up
> automatically. Since the file is new, `git add` it so Nix sees it.

## Joining the Noxa mesh

`noxa.managedNodes` defaults to every host ez-configs discovers, so most
setups need no extra step. Set it explicitly to narrow the list, for example
to exclude an ISO installer configuration that should stay outside the mesh:

```nix
{
  noxa.managedNodes = [ "my-node" "other-node" ]; # excludes e.g. "iso"
}
```

Noxa's own cross-host modules (wireguard, SSH) use this list to validate
references and to iterate over every managed host.

## Default values for all hosts

To apply NixOS configuration to every host, add a file to
`ezConfigs.nixos.modulesDirectory` (`./nixos-modules` by default).
Ez-configs imports it into every host automatically:

```nix
# nixos-modules/default.nix
{ ... }: {
  # default configuration for all hosts
  # ...
}
```

## Nixpkgs versions

Each host is built with whichever `nixpkgs` you pass to its own
`nixosSystem` call (through ez-configs). Noxa does not impose a shared
version. Use a different `nixpkgs` input for a specific host the same way
you would in any multi-host flake-parts setup.
