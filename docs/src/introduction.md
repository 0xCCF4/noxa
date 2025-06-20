# Intro

**Noxa** is a tool to ease the configuration of multi-host NixOS configurations.
Starting with the motivation, design goals, and design decisions, this handbook guides
you through setting up a multi-host NixOS configuration.

## Motivation

NixOS is a Linux distribution configuration solution composed of modules and packages [NixOS Manual](https://nixos.org/manual/nixos/stable/#preface). While [nixpkgs](https://github.com/NixOS/nixpkgs/) provides many modules for configuring NixOS machines, it lacks fundamental support for configuration beyond the scope of a single host.

In practice, some hosts share configuration settings. Imagine that you configure four different NixOS machines and would like to set up a Wireguard network between them. In the end, you will configure `networking.wireguard.interfaces.<name>` on each host, but there are several open questions:
1. How do you manage secrets? For some secrets, how do you share public interface keys with each host or handle connection keys shared between two hosts?
2. Some hosts will have public IP addresses and a direct connection should be established, while others take on a client role and do not own a public IP address. The trait of having a public IP address will ultimately belong to the configuration of each host, while each other host needs to configure their connection settings accordingly.

To summarize, there are configuration settings shared among different hosts and do not belong to any specific one, and there are configuration values owned by hosts but accessed by others to configure their NixOS configuration.

Currently, [nixpkgs](https://github.com/NixOS/nixpkgs/) does not support these multi-host configuration scenarios and multi-host dependency.

## Goal

The goal of **Noxa** is to fill this gap and provide a framework to support the configuration of hosts that depend on each other.

## Contributing

Contributions are welcome. Suggest new features and bugs via issue. Pull requests are welcome.


## Related projects

Other frameworks already aim to implement multi-host NixOS configuration; the list is provided below.
Why another framework? 1. Because of the following design goal: Plug-and-play, new hosts added, should have minimal configuration already configured according to the existing hosts. 2. Learning of Nix language and ecosystem.

List of other multi-host configuration framework (feel free to add others):
- [nixus](https://github.com/infinisil/nixus/)