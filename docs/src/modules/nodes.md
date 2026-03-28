# Nodes

The nodes module allows definition of hosts and their NixOS configuration.

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

