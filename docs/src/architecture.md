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

    nodeNames = [ "my-node" "other-node" ];
}
```
Global imports and modules might, therefore, be placed in the `defaults` configuration, while node-specific imports and modules can be placed in the node configuration.

> Note the `nodeNames` attribute, which is a list of all node names. This is currently required, when you write noxa modules that go over all nodes, and will set properties on them. To prevent infinite recursion on module evaluation, we added this attribute, so that the module can know which nodes there are, without having to look at the `nodes` attribute itself.
>
> If you have suggestion on how to circumvent recursion in this case, please let us know via an issue or PR.

### Nixpkgs versions
By default, all nodes share the same `nixpkgs` version, which is inherited from the `nixpkgs` version
you specified for *noxa* itself.
```nix
{ # flake configuration
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nixpkgs stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.11";

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
{nixpkgs-stable, ...}: {
    nodes."my-node" = {
        nixpkgs = nixpkgs-stable; # use a different nixpkgs version for this node
    };
}
```
This node will then use the `nixpkgs-stable` version of `pkgs` and module system.

## Module system
Internally *noxa* uses the same module system to evaluate the configuration files like nixos does; via
the `nixpkgs.lib.evalModules` function. You can, therefore, specify your (initial) modules and special args, when calling the `noxa-instantiate` function.

To evaluate the configuration of a single node *noxa* will call the `<nixpkgs>/nixos/lib/eval-config.nix` which would
normally be called via calling `<nixpkgs>.lib.nixosSystem`.

By default, we pass down the following additional special args to *noxa* modules:
- `noxa`: The *noxa* flake itself
- `noxa.nixpkgs`: The nixpkgs, *noxa* uses during its module system evaluation.
- `noxa.nixosModules`/`noxa.noxaModules`: The list of modules specified in the *noxa* flake
- `noxa.lib`: Utility functions provided by *noxa*.
- `noxa.lib.net`: Network related utility functions, vendored from `nix-net-lib`

To each *nixos* host evaluation, *noxa* will pass down the following additional special args:
- `agenix`: The agenix module specified in the *noxa* flake
- `agenix-rekey`: The agenix-rekey module specified in the *noxa* flake
- `noxa`: See above, minus the `nixpkgs`
- `noxaHost`/`name`: The node name of the host being evaluated
- `noxaConfig`: The top-level `config` attribute of the `noxa` module system evaluation
- `nodes`: The `nodes.<name>.configuration` attribute of the `noxa` module system evaluation
