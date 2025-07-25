## noxa\.info\.reachable\.allowHostConfiguration

Allow the host to configure its own reachable addresses\. If set to false, values can only be set on the Noxa module level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/info.nix)



## noxa\.info\.reachable\.internet



List of external IP addresses this host is reachable at via using a public IP address\.



*Type:*
list of (IPv4 address or IPv6 address)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/info.nix)



## noxa\.info\.reachable\.wireguardNetwork



List of IP addresses this host is reachable at via WireGuard (specified via name)\.



*Type:*
attribute set of list of (IPv4 address or IPv6 address)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/nixos/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/info.nix)


