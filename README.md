# noxa

**Noxa** is a management tool for multi-host NixOS configurations.

> **Status:** Experimental early development phase, under active development.  
> Interfaces and features may change at any time.
> Breaking changes and incomplete features are to be expected.

## Goals

- Provide a foundation for managing and coordinating multiple NixOS hosts from a single codebase.
- Enable cross-host configuration, secret management, and network setup for complex environments.

## Features

- **Multi-host configuration:** Define and manage several NixOS machines in a unified structure.
- **Cross-host modules:** Write modules that can coordinate settings and state between hosts.
- **Secret management:** Automated secret management for (cross-host) distributed systems (e.g., WireGuard keys, SSH host keys).
- **Modularity:** Just use the features you need.


## Getting Started

See the [examples](examples/) directory for sample multi-host configurations and usage patterns.

## Other related projects
- [nixus](https://github.com/infinisil/nixus/)

## Contributing

Contributions are welcome! Open an issue with a feature request, bug report or submit a pull request to get involved.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.