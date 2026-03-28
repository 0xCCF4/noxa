# SSH Module

The SSH module automated the distribution of SSH host config between managed hosts.

By specifying which user on which node has access to which user on a different node, SSH configuration and authorized SSH keys can be generated and distributed automatically.

## Internal workings
The SSH module automates the following steps:
1. Generation and distribution of SSH keypairs (via [Secrets module](./secrets.md)).
2. Configuration of authorizedKey on the target node for the targetUser (via [users.users.<name>.openssh.authorizedKeys](https://search.nixos.org/options?channel=unstable&show=users.users.<name>.openssh.authorizedKeys.keys)).
3. Configuration of the .ssh/config file on the source node to allow easy access to the target node (via [Home Manager](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.matchBlocks)).

## Usage
When adding a new grant, renaming a grant, new secrets need to be rolled out to the affected nodes. This can be done by running `agenix generate` (to generate new secrets) and `agenix rekey` (to distribute the new secrets to the affected nodes).

For a detailed list of options, see the [SSH module reference](../options/ssh.nixos.md). Below are some common examples of usage.

## Examples

### Simple connection
Allow `bob@source` to SSH into `alice@target`:

```nix
nodes.source.configuration.ssh.grants = {

 # name of the grant, can be anything
 access = {
      
   # connection settings
   from = "bob";
   to.node = "target";
   to.user = "alice";

 };
};
```

### Restrict commands on the target node
Allow `bob@source` to SSH into `alice@target` but only allow running the `uptime` or `date` command:


```nix
nodes.source.configuration.ssh.grants = {

 # name of the grant, can be anything
 uptime = {
      
   # connection settings
   from = "bob";
   to.node = "target";
   to.user = "alice";
   
   commands = {pkgs}: [
     "${pkgs.coreutils}/bin/uptime"
     "${pkgs.coreutils}/bin/date"
   ];

   # provide a list of allowed commands when no valid command is provided
   showAvailableCommands = true;
 };
};
```

### Port forwarding
Allow `bob@source` to SSH into `alice@target` but only allow port forwarding on port 5555, no shell access:

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