# noxa

**Noxa** is a management tool for multi-host NixOS configurations.

> **Status:** Under active development.  
> Interfaces and features are subject to change.
>
> Though, it is in a usable state, as I ([@0xCCF4](https://github.com/0xCCF4/)) use it as my daily driver for my NixOS setup.

## Goals

- Provide a foundation for managing and coordinating multiple NixOS hosts from a single codebase.
- Enable cross-host configuration, secret management, and network setup for complex environments.

## Features

- **Multi-host configuration:** Define and manage several NixOS machines in a unified structure.
- **Cross-host modules:** Write modules that can coordinate settings and state between hosts.
- **Secret management:** Automated secret management for (cross-host) distributed systems (e.g., WireGuard keys, SSH host keys).
- **Wireguard networks:** Easy setup of wireguard overlay networks with automatic key exchanges.
- **SSH setup:** Setup of cross-device SSH access with automatic SSH keypair key exchange and per-connection SSH options.
- **Modularity:** Just use the features you need.


## Getting Started

1. The official documentation is available here: <https://0xccf4.github.io/noxa/>
2. A minimal working example can be found in the [examples](examples/) folder.
3. My ([@0xCCF4](https://github.com/0xCCF4/)) daily used nixos configuration, using **Noxa**, can be found here: [github:0xCCF4/system](https://github.com/0xCCF4/system)

## Other related projects
- [nixus](https://github.com/infinisil/nixus/)

## Contributing

Contributions are welcome! Open an issue with a feature request, bug report or submit a pull request to get involved.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.