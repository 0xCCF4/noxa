# noxa

**Noxa** is a harness and a set of NixOS modules that make cross-host
features easy in multi-host NixOS configurations.

Noxa builds on [ez-configs](https://github.com/ehllie/ez-configs). ez-configs
already discovers and builds many hosts from one flake. Noxa adds what
ez-configs does not have: shared options for the whole fleet and modules that
configure several hosts together.

> **Status:** Under active development.  
> Interfaces and features are subject to change.
>
> Though, it is in a usable state and I ([@0xCCF4](https://github.com/0xCCF4/)) use it as my daily driver of my NixOS setup.

## Goals

- Give a harness on top of ez-configs for options and modules that span several hosts.
- Give ready-to-use modules for common cross-host tasks: secret management, network setup, and SSH access.

## Features

- **Harness:** A flake-parts module for ez-configs. It adds the list of managed hosts, fleet-wide options, and the `noxa` special argument to every host.
- **Cross-host modules:** Write modules that coordinate settings and state between hosts.
- **Secret management:** Automated secret management for (cross-host) distributed systems (e.g., WireGuard keys, SSH host keys).
- **Wireguard networks:** Easy setup of wireguard overlay networks with automatic key exchanges.
- **SSH setup:** Setup of cross-device SSH access with automatic SSH keypair key exchange and per-connection SSH options.
- **Modularity:** Just use the features you need.


## Getting Started

1. The official documentation is available here: <https://0xccf4.github.io/noxa/>
2. A minimal working example can be found in the [examples](examples/) folder.
3. My ([@0xCCF4](https://github.com/0xCCF4/)) daily used nixos configuration, using **Noxa**, can be found here: [github:0xCCF4/system](https://github.com/0xCCF4/system)

## Contributing

Contributions are welcome! Open an issue with a feature request, bug report or submit a pull request to get involved.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.