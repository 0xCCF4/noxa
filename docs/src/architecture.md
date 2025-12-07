# Architecture
Below we explain internal concepts of *noxa*.

## Nodes
When we talk about the machines that are configured via *noxa* we use the term "node". A node has
a single unique name, which is used to identify it. This name is specified when declaring a node
```nix
{
    nodes."my-node" = { ... };
}
```

Note that: the name of the node is not necessarily the same as the hostname of the machine. When
referring nodes in the configuration, we always use the node name, never the hostname.

### Declaring node configuration
The configuration of a node is comprised of the default configuration, shared among all nodes, and the node-specific configuration. The default configuration is specified using the `defaults` attribute, while the node-specific configuration is specified under the node name. For example:
```nix
{
    defaults.configuration = {
        networking.hostName = mkDefault "abc";
    };

    nodes."my-node" = {
        # node-specific configuration
        networking.hostName = "my-node";
    };

    nodes."other-node" = {
        # node-specific configuration
        # inherits the default hostName "abc"
    };
}
```
Global imports and modules might, therefore, be placed in the `defaults` configuration, while node-specific imports and modules can be placed in the node configuration.

### Nixpkgs versions
By default, all nodes share the same `nixpkgs` version, which is inherited from the `nixpkgs` version
you specified for *noxa* itself.
```nix
{ # flake configuration
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Noxa
    noxa = {
      url = "github:0xCCF4/noxa";
      inputs.nixpkgs.follows = "nixpkgs"; # use the nixpkgs version above
    };
  };
}
```
However, you can specify that a single node use a different `nixpkgs` version, by setting the `nixpkgs` attribute in the node configuration, e.g.:
```nix
{
    nodes."my-node" = {
        nixpkgs = nixpkgs-stable; # use a different nixpkgs version for this node
    };
}
```
This node will then use the `nixpkgs-stable` version of `pkgs` and module system, while all other nodes will use the `nixpkgs` version that *noxa* uses.



## Module system
Internally *noxa* uses the same module system to evaluate the configuration files like nixos does; via
the `nixpkgs.lib.evalModules` function. You can, therefore, specify your (initial) modules and special args, when calling the `noxa-instantiate` function.

To evaluate the configuration of a single node


# Todos
- module System
- specialArgs
- use single module
- nodes vs hostnames
- defaults
- nodeNames
- node nixpkgs