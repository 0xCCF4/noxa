# SSH Module

The SSH module automates SSH configuration between managed hosts.

Declare which user on which host may access which user on another host, and
Noxa generates the SSH keys, sets the authorized key on the target, and
writes the SSH client config on the source.

## Internal workings
The SSH module automates these steps:
1. Generates and distributes SSH keypairs (through the [Secrets module](./secrets.md)).
2. Sets the authorized key on the target host, for the target user (through [users.users.<name>.openssh.authorizedKeys](https://search.nixos.org/options?channel=unstable&show=users.users.<name>.openssh.authorizedKeys.keys)).
3. Configures the `.ssh/config` file on the source host, for easy access to the target (through [Home Manager](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.matchBlocks)).

## Usage
A host needs `noxa.nixosModules.ssh` imported before it can declare or
receive `ssh.grants`. After adding, renaming, or removing a grant, roll out
the new secrets with `agenix generate` (generates new secrets) and
`agenix rekey` (distributes them to the affected hosts).

For a full option reference, see the [SSH module reference](../options/ssh.nixos.md).
Below are common examples.

## Examples

### Simple connection
Allow `bob@source` to SSH into `alice@target`:

```nix
# hosts/source.nix
{ noxa, ... }: {
  imports = [ noxa.nixosModules.ssh ];

  ssh.grants.access = {
    # connection settings
    from = "bob";
    to.node = "target";
    to.user = "alice";
  };
}
```

### Restrict commands on the target host
Allow `bob@source` to SSH into `alice@target`, but only to run `uptime` or
`date`:

```nix
# hosts/source.nix
{ noxa, ... }: {
  imports = [ noxa.nixosModules.ssh ];

  ssh.grants.uptime = {
    # connection settings
    from = "bob";
    to.node = "target";
    to.user = "alice";

    commands = { pkgs }: [
      "${pkgs.coreutils}/bin/uptime"
      "${pkgs.coreutils}/bin/date"
    ];

    # list the allowed commands when the user runs something else
    showAvailableCommands = true;
  };
}
```

### Port forwarding
Allow `bob@source` to SSH into `alice@target`, but only to forward port
5555, with no shell access:

```nix
# hosts/source.nix
{ noxa, ... }: {
  imports = [ noxa.nixosModules.ssh ];

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
