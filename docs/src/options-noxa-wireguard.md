## wireguard



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.allowNodesToJoin



If set to true, nodes may join this network by declaring ` noxa.wireguard.interfaces.<interface> `\.
If set to false, nodes may only join this network if declared in this network configuration\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members



Configuration of the wireguard members\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.keepAlive



The keep alive interval remote peers should use when communicating with this interface\.

If set to any other value than null, the value will be applied to the nodes configuration\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.server



Options for wireguard servers\. If a wireguard interface is regarded as a server (e\.g\. since it has a public IP address), it may advertise its service via the ` server.advertise ` option\.

If set, all peers that would like to connect to that peer will use the advertised listen port and address as means of directly connecting to the server\.

Further, if ` server.defaultGateway ` is set, all peers that do not advertise listen port and address will be reached via the server marked as default gateway\. Therefore, only one interface may be marked as default gateway at any time\.

If set to any other value than null, the value will be applied to the node configuration\.



*Type:*
null or (submodule)



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.server\.defaultGateway



If set, this server will be the default gateway for clients\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.server\.firewallAllow



If set, the nixos firewall will allow incoming connections to the advertised listen port\.

If set to any other value than null, the value will be applied to the node configuration\.



*Type:*
null or boolean



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.server\.listenAddress



The address this server will listen on for incoming connections\.



*Type:*
IPv4 address or IPv6 address

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.advertise\.server\.listenPort



The port this server will listen on for incoming connections\.



*Type:*
signed integer

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.autostart



Specifies whether to autostart the WireGuard interface\.

Only relevant if the ` backend ` is set to ` wg-quick `\.

If set to any other value than null, the value will be applied to the node configuration\.



*Type:*
null or boolean



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.backend



The backend to use for WireGuard config generation\.

 - ` wireguard `: Uses the ` networking.wireguard.interfaces ` module to generate the configuration\.
 - ` wg-quick `: Uses the ` networking.wg-quick.interfaces ` module to generate the configuration\.

If set to any other value than null, the value will be applied to the node configuration\.



*Type:*
null or one of “wireguard”, “wg-quick”



*Default:*
` "wireguard" `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.deviceAddresses



List of ip addresses to assign to this interface\. The server will forward traffic
to these addresses\.



*Type:*
null or ((list of (IPv4 address or IPv6 address)) or (IPv4 address or IPv6 address) convertible to it)



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.gatewayOverride



If set, this interface will use the specified node as the gateway for connecting to the wireguard network\.

If set to any other value than null, the value will be applied to the nodes configuration\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.keepAlive



The default keep alive interval this interface will use when communicating with remote peers\.

If the remote end uses ` advertise.keepAlive `, the minimum value of both will be used\.

If set to any other value than null, the value will be applied to the nodes configuration\.



*Type:*
null or signed integer



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.members\.\<name>\.onlySpecifiedDeviceAddresses



If set to true, device addresses set by the node configuration are rejected\.
If set to false, the node might add additional device addresses to the interface\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)



## wireguard\.\<name>\.networkAddress



The network address of the wireguard network\.



*Type:*
IPv4 address, normalized network address, or (IPv6 address, normalized network address)

*Declared by:*
 - [noxa/modules/noxa/wireguard\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/wireguard.nix)


