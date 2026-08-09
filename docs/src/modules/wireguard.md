# Wireguard Module

The WireGuard module declares an overlay network once and configures every
member host from that single declaration. It exchanges connection keys
through the secrets module, picks gateways and routes for hosts behind NAT
or without a public IP, and still allows direct peer-to-peer connections
between hosts that can reach each other.

## Internal workings
A network's topology (its address range, its members, and how they connect)
does not belong to any single host, so it lives in your flake-parts
configuration under `noxa.wireguard`, not inside a host's own file. Each
member host imports `noxa.nixosModules.wireguard`, which reads its share of
that topology and turns it into local WireGuard configuration:
1. Reads which networks list this host as a member.
2. Picks a gateway per network, honoring a manual `gatewayOverride` if you set one.
3. Generates and exchanges keys through the [Secrets module](./secrets.md).
4. Configures `networking.wireguard.interfaces` or `networking.wg-quick.interfaces`, depending on the network's `backend`.

A host may also report its own public reachability through
`noxa.wireguard.reachable.internet`; when a network sets
`autoConfigureGateway = true` (the default), Noxa uses that to pick a
gateway automatically instead of requiring `advertise.server` set by hand.

## Usage
After you add, remove, or change network membership, roll out the new
secrets with `agenix generate` (generates new secrets) and `agenix rekey`
(distributes them to the affected hosts).

For a full option reference of what a member host ends up with, see the
[Wireguard module reference](../options/wireguard.nixos.md).

## Example

Declare a network and its members in your flake-parts configuration:
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

Then import the module on each member host:
```nix
# hosts/someHost.nix
{ ... }: {
  imports = [ inputs.noxa.nixosModules.wireguard ];
}
```

Run `agenix generate`, then `agenix rekey`.
