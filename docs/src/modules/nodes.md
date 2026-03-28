# Nodes

The nodes module allows definition of hosts and their NixOS configuration.

## Defining nodes

A node is defined via
```nix
nodes.<name>.configuration = {
  # (NixOS) configuration of the node <name>
  # ...
};
nodeNames = [ "<name>" ];
```

> If you use the template, the nodes are automatically added
to the `nodeNames` list.

## Default values for all nodes

Default nixos configuration values for all nodes (or imports)
may be specified via the `defaults` attribute, which
is inherited by all nodes.

```nix
defaults.configuration = {
  # default configuration for all nodes
  # ...
};
```

## Nixpkgs versions

Each host may use its own version of nixpkgs which can be
specified via the `nixpkgs` attribute. If not specified, the node inherits the nixpkgs version from the noxa framework.
