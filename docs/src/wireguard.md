## noxa\.wireguard\.enable

Enables the WireGuard module, which a cross-host VPN setup utility for wireguard\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces



A set of WireGuard interfaces to configure\. Each interface is defined by its name and
contains its private key, public key, and listen port\.



*Type:*
lazy attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.keepAlive



The keep alive interval remote peers should use when communicating with this interface\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.server



Options for wireguard servers\. If a wireguard interface is regarded as a server (e\.g\. since it has a public IP address), it may advertise its service via the ` server.advertise ` option\.

If set, all peers that would like to connect to that peer will use the advertised listen port and address as means of directly connecting to the server\.

Further, if ` server.defaultGateway ` is set, all peers that do not advertise listen port and address will be reached via the server marked as default gateway\. Therefore, only one interface may be marked as default gateway at any time\.



*Type:*
null or (submodule)



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.server\.defaultGateway



If set, this server will be the default gateway for clients\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.server\.firewallAllow



If set, the nixos firewall will allow incoming connections to the advertised listen port\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.server\.listenAddress



The address this server will listen on for incoming connections\.



*Type:*
IPv4 address or IPv6 address

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.advertise\.server\.listenPort



The port this server will listen on for incoming connections\.



*Type:*
signed integer

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.autostart



Specifies whether to autostart the WireGuard interface\.

Only relevant if the ` backend ` is set to ` wg-quick `\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.backend



The backend to use for WireGuard config generation\.

 - ` wireguard `: Uses the ` networking.wireguard.interfaces ` module to generate the configuration\.
 - ` wg-quick `: Uses the ` networking.wg-quick.interfaces ` module to generate the configuration\.



*Type:*
one of “wireguard”, “wg-quick”



*Default:*
` "wireguard" `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.deviceAddresses



List of ip addresses to assign to this interface\. The server will forward traffic
to these addresses\.



*Type:*
list of (IPv4 address or IPv6 address)

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.gatewayOverride



If set, this interface will use the specified hostname as the gateway for connecting to the wireguard network\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.keepAlive



The default keep alive interval this interface will use when communicating with remote peers\.

If the remote end uses ` advertise.keepAlive `, the minimum value of both will be used\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.kind\.isClient



This interface has the role of a client, meaning it does not advertise other peers to connect to it\. Instead, it connects to other peers, initiating the connection\.



*Type:*
boolean *(read only)*



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.kind\.isGateway



This interface is a server and is marked as the default gateway for clients\.
This means that clients will use this interface to reach other peers that do not advertise their listen port and address\.



*Type:*
boolean *(read only)*



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.kind\.isServer



This interface has the role of a server, meaning it advertises its listen port and address to peers\.



*Type:*
boolean *(read only)*



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.interfaces\.\<name>\.networkAddress



The network IP addresses\. On clients, traffic of this network will be routed through the WireGuard interface\.



*Type:*
IPv4 address, normalized network address, or (IPv6 address, normalized network address)

*Declared by:*
 - [noxa/modules/nixos/wireguard/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/options.nix)



## noxa\.wireguard\.routes



A set of intermediary connection information, automatically computed from the nixos configurations\.



*Type:*
lazy attribute set of (submodule) *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.neighbors



A set of connections for this interface, automatically computed from the nixos configurations\.



*Type:*
lazy attribute set of (submodule) *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.neighbors\.\<name>\.keepAlive



The keep-alive interval for this connection, in seconds\.
If set to ` null `, no keep-alive is configured\.



*Type:*
null or signed integer *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.participants\.clients



A list of clients for this interface\. Automatically populated\.



*Type:*
list of string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.participants\.gateways



A list of gateways for this interface\. Automatically populated\.



*Type:*
list of string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.participants\.servers



A list of servers for this interface\. Automatically populated\.



*Type:*
list of string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.peers



A list of peers for this interface\. Automatically populated\.



*Type:*
list of (submodule) *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.peers\.\*\.target



The target hostname of the connection\.



*Type:*
string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.routes\.\<name>\.peers\.\*\.via



The hostname of the peer this connection is routed through\.



*Type:*
null or string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/routes\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/routes.nix)



## noxa\.wireguard\.secrets



A set of wireguard secrets\. When using the ` .interfaces ` options,
this set is automatically populated\. Each peer will own its own
set of secrets



*Type:*
lazy attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/nixos/wireguard/secrets\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/secrets.nix)



## noxa\.wireguard\.secrets\.\<name>\.presharedKeyFiles



The pre-shared key file for each peer (by hostname) of the wireguard interface



*Type:*
lazy attribute set of string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/secrets\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/secrets.nix)



## noxa\.wireguard\.secrets\.\<name>\.privateKeyFile



The private key file of the wireguard interface



*Type:*
string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/secrets\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/secrets.nix)



## noxa\.wireguard\.secrets\.\<name>\.publicKey



The public key the wireguard interface



*Type:*
string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/wireguard/secrets\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/wireguard/secrets.nix)


