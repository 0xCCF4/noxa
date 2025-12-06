## defaults

Default options applied to all nodes\.



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## defaults\.build\.toplevel



Build this node’s configuration into a NixOS system package\.

Alias to ` config.system.build.toplevel `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## defaults\.build\.vm



Build this node’s configuration into a VM testing package\.

Alias to ` config.system.build.vm `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## defaults\.nixpkgs



The nixpkgs version to use when building this node\.

By default, if not explicitly set, it uses the same version than the Noxa flake itself\.



*Type:*
absolute path



*Default:*
` "<nixpkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.options



The contents of the options defined by the nixpkgs module for this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<options>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.pkgs



The pkgs set with overlays and for the target system of this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<pkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.reachable\.allowHostConfiguration



Allow the host to configure its own reachable addresses\. If set to false, values can only be set on the Noxa module level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.reachable\.internet



List of external IP addresses this host is reachable at via using a public IP address\.



*Type:*
list of (IPv4 address or IPv6 address)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.reachable\.wireguardNetwork



List of IP addresses this host is reachable at via WireGuard (specified via name)\.



*Type:*
attribute set of list of (IPv4 address or IPv6 address)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.specialArgs



Special arguments passed to the host modules\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/configuration\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/configuration.nix)



## nodeNames



A list of node names managed by Noxa\. Due to the architecture of Noxa,
noxa modules might unwillingly create new nodes, this list contains the name of all nodes
that are currently managed by Noxa\. Noxa modules can check this list to see if a node
was created by themselves\.

````
  The user must set this to the listOf all nodes they want to manage, otherwise if you
  don't care, set this to `attrNames config.nodes`.
````



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## nodes



A set of nixos hosts managed by Noxa\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## nodes\.\<name>\.build\.toplevel



Build this node’s configuration into a NixOS system package\.

Alias to ` config.system.build.toplevel `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## nodes\.\<name>\.build\.vm



Build this node’s configuration into a VM testing package\.

Alias to ` config.system.build.vm `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## nodes\.\<name>\.nixpkgs



The nixpkgs version to use when building this node\.

By default, if not explicitly set, it uses the same version than the Noxa flake itself\.



*Type:*
absolute path



*Default:*
` "<nixpkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.options



The contents of the options defined by the nixpkgs module for this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<options>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.pkgs



The pkgs set with overlays and for the target system of this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<pkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.reachable\.allowHostConfiguration



Allow the host to configure its own reachable addresses\. If set to false, values can only be set on the Noxa module level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.reachable\.internet



List of external IP addresses this host is reachable at via using a public IP address\.



*Type:*
list of (IPv4 address or IPv6 address)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.reachable\.wireguardNetwork



List of IP addresses this host is reachable at via WireGuard (specified via name)\.



*Type:*
attribute set of list of (IPv4 address or IPv6 address)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.specialArgs



Special arguments passed to the host modules\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/configuration\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/configuration.nix)


