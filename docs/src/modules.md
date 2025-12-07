# Modules
Below you find a short summary of functionality of the different modules
comprising *noxa*.

## Nodes

The core framework consists of the [Nodes](./modules/nodes.md) module,
providing definitions of hosts.

## SSH

The [SSH module](./modules/ssh.md) allows automatic configuration of SSH authorized keys
between different hosts. You might for example want that some user (bob@source) can log in
to a specific host (alice@destination) to forward the port 5555. This can be achieved by
the following configuration, automatically creating required SSH keys, setting up
authorized keys with connection restrictions, and configuration of the SSH config files.

```nix
nodes.source.configuration.ssh.grants = {

 # name of the grant, can be anything
 portForwarding = {
      
   # connection settings
   from = "bob";
   to.node = "target";
   to.user = "alice";

   # configure client side options
   to.extraOptions = {

     # extra option to the home manager SSH module
     localForward = [
       bind.port = 5555;
       host.address = "127.0.0.1";
       host.port = 5555;
     ];

     extraOptions = {
       # dont open a shell, only port forwarding
       SessionType = "none";
     };

   };

   # configure server side options
   options.open = ["127.0.0.1:5555"];
   
   commands = {pkgs}: [ # only allow port forwarding, no shell or other commands
     "${pkgs.coreutils}/bin/false"
   ];
 };
};
```

Now run `agenix generate`, then `agenix rekey` and voila.

## Secrets

[This module](./modules/secrets.md) allows configuring of host specific and shared secrets.

For example when setting up a wireguard network, connection keys are neither owned by any
of both peers. *noxa* will manage these shared secrets and make them available to the respective hosts. 
Under the hood, *noxa* uses `agenix` and `agenix-rekey` to manage these secrets, but adds required functionality
for above mentioned use cases.

```nix
nodes.example.configuration = {
  noxa.secrets.def = [
    
    { # shared secret between "source" and "target"
      ident = "connection-psk-example";
      module = "noxa.wireguard";
      hosts = [ "source" "target" ];
      generator.script = "wireguard-psk";
    }
    
    { # host specific secret
      ident = "interface-key-example";
      module = "noxa.wireguard";
      generator.script = "wireguard-key";
    }

    { # instance wide secret, not assigned to any host
      ident = "instance-wide-secret";
      module = "something";
      global = true;
    }

  ];
};
```

## Wireguard

This module allows the declaration of wireguard overlay networks
to connect several hosts together. It uses the secrets module to automatically
exchange secrets between the hosts, configures gateways and routing in case of
hosts being behind NAT/without public IPs, while also allowing direct peer to peer
connections for hosts reachable by each other.

```nix
wireguard.overlay-lan = {
  networkAddress = "10.0.0.0/24";

  members = {
    # define a host "someHost" as a member of this wireguard network 
    someHost.deviceAddresses = "10.0.0.1/32";
    someHost.backend = "wg-quick";
    someHost.advertise.server.listenPort = 51823;
    someHost.advertise.server.firewallAllow = true;

    # define another host "otherHost" as a member of this wireguard network
    otherHost.deviceAddresses = "10.0.0.2/32";
    otherHost.keepAlive = 30;
  };
};
```

Now run `agenix generate`, then `agenix rekey` and voila.