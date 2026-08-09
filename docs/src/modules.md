# Modules

This page summarizes the modules that make up *noxa*.

## Hosts

[ez-configs](https://github.com/ehllie/ez-configs) discovers your hosts, and
the [Hosts](./modules/nodes.md) page covers how Noxa's own
`noxa.managedNodes` option fits on top of that.

## SSH

The [SSH module](./modules/ssh.md) configures SSH authorized keys between
hosts automatically. Say user `bob@source` should be able to log in to
`alice@destination` to forward port 5555. Import `noxa.nixosModules.ssh` on
both hosts, then declare the grant on the source host. Noxa generates the
SSH keys, sets up the authorized key with the right restrictions, and writes
the SSH client config for you.

```nix
# hosts/source.nix
{ ... }: {
  imports = [ inputs.noxa.nixosModules.ssh ];

  ssh.grants.portForwarding = {
    # connection settings
    from = "bob";
    to.node = "target";
    to.user = "alice";

    # configure client side options
    to.extraOptions = {
      # extra option to the home manager SSH module
      LocalForward = [
        bind.port = 5555;
        host.address = "127.0.0.1";
        host.port = 5555;
      ];

      # don't open a shell, only port forwarding
      SessionType = "none";
    };

    # configure server side options
    options.open = [ "127.0.0.1:5555" ];

    commands = { pkgs }: [ # only allow port forwarding, no shell or other commands
      "${pkgs.coreutils}/bin/false"
    ];
  };
}
```

Run `agenix generate`, then `agenix rekey`.

## Secrets

The [Secrets module](./modules/secrets.md) configures host-specific and
shared secrets.

A WireGuard connection key, for example, belongs to neither peer alone.
Import `noxa.nixosModules.secrets` on a host to declare secrets for it.
Noxa manages the shared ones and makes them available to every host that
needs them. Under the hood, Noxa uses `agenix` and `agenix-rekey`, adding
the multi-host bookkeeping on top.

```nix
# hosts/example.nix
{ ... }: {
  imports = [ inputs.noxa.nixosModules.secrets ];

  noxa.secrets.def = [
    { # shared secret between "source" and "target"
      ident = "connection-psk-example";
      module = "noxa.wireguard";
      hosts = [ "source" "target" ];
      generator.script = "wireguard-psk";
    }

    { # host-specific secret
      ident = "interface-key-example";
      module = "noxa.wireguard";
      generator.script = "wireguard-key";
    }

    { # instance-wide secret, not assigned to any host
      ident = "instance-wide-secret";
      module = "something";
      global = true;
    }
  ];
}
```

## Wireguard

The [Wireguard module](./modules/wireguard.md) declares WireGuard overlay
networks that connect several hosts. It uses the secrets module to exchange
keys automatically, configures gateways and routing for hosts behind NAT or
without a public IP, and still allows direct peer-to-peer connections where
hosts can reach each other.

The network topology belongs to no single host, so it lives in your
flake-parts configuration, under `noxa.wireguard`:

```nix
noxa.wireguard.overlay-lan = {
  networkAddress = "10.0.0.0/24";

  members = {
    # declare "someHost" as a member of this network
    someHost.deviceAddresses = "10.0.0.1/32";
    someHost.backend = "wg-quick";
    someHost.advertise.server.listenPort = 51823;
    someHost.advertise.server.firewallAllow = true;

    # declare "otherHost" as a member of this network
    otherHost.deviceAddresses = "10.0.0.2/32";
    otherHost.keepAlive = 30;
  };
};
```

Each member host must import `noxa.nixosModules.wireguard` to pull in its
share of this topology. Run `agenix generate`, then `agenix rekey`.
