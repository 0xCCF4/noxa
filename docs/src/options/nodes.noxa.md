## defaults

Default options applied to all nodes\.



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## defaults\.build\.toplevel



Build this node’s configuration into a NixOS system package\.

Alias to ` config.system.build.toplevel `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## defaults\.build\.vm



Build this node’s configuration into a VM testing package\.

Alias to ` config.system.build.vm `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## defaults\.nixpkgs



The nixpkgs version to use when building this node\.

By default, if not explicitly set, it uses the same version than the Noxa flake itself\.



*Type:*
absolute path



*Default:*
` "<nixpkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.options



The contents of the options defined by the nixpkgs module for this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<options>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.pkgs



The pkgs set with overlays and for the target system of this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<pkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## defaults\.reachable\.allowHostConfiguration



Allow the host to configure its own reachable addresses\. If set to false, values can only be set on the Noxa module level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.reachable\.internet



List of external IP addresses this host is reachable at via using a public IP address\.



*Type:*
list of (IPv4 address or IPv6 address)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.reachable\.wireguardNetwork



List of IP addresses this host is reachable at via WireGuard (specified via name)\.



*Type:*
attribute set of list of (IPv4 address or IPv6 address)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## defaults\.specialArgs



Special arguments passed to the host modules\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/configuration\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/configuration.nix)



## defaults\.ssh\.grants



Grant SSH access from from node users to to node users\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.commands



Function that evaluates to a list of commands the user is allowed to execute on the target node\. If empty, all commands are allowed\.

This function will be called with the pkgs\.callPackage function taken from the target node\.



*Type:*
function that evaluates to a(n) list of ((submodule) or package convertible to it)



*Default:*
` <function> `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.aliases



The SSH command that is requested by the user, mapping to this command\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.command



The command to allow\.



*Type:*
string or package convertible to it

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.passParameters



Whether to pass any parameters given by the user to the command\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.extraConnectionOptions



Additional SSH connection options to use when connecting to the target node\.

View man SSH(8) - AUTHORIZED_KEYS



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.from



Source user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.name



Alias name under which the user can ` ssh {alias} ` to the target\.



*Type:*
string



*Default:*
` "<name>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.agentForwarding



Apply the “agent-forwarding” option to this SSH key, allowing SSH agent forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.listen



Apply the “permitlisten” option to this SSH key, remote listening and
forwarding of ports to local ports\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.open



Apply the “permitopen” option to this SSH key, allowing to open
specific host:port combinations\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.pty



Apply the “pty” option to this SSH key, allowing to allocate a pseudo-terminal\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.restrict



Apply the “restrict” option to this SSH key, disabling every feature
except executing commands\. Disabling this option, will circumvent all
other options set via \.options \.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.options\.x11Forwarding



Apply the “x11-forwarding” option to this SSH key, allowing X11 forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.resolvedCommands



The resolved commands after evaluating the ` commands ` function\.



*Type:*
(list of ((submodule) or package convertible to it)) or string *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.showAvailableCommands



If set to true, when the user tries to execute an unauthorized command,
the list of available commands will be shown\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.sshGenKeyType



When generating SSH keys use this key type\.



*Type:*
one of “ed25519”, “rsa”



*Default:*
` "ed25519" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to



Destination node and user\.



*Type:*
submodule



*Default:*
` "<to>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to\.hostname



Hostname or IP address of the target node\.



*Type:*
string



*Default:*
` "<to.node>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to\.node



Destination node name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to\.port



SSH port of the target node\.



*Type:*
signed integer



*Default:*
` 22 `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to\.sshFingerprint



Expected SSH host key fingerprint of the destination node\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## defaults\.ssh\.grants\.\<name>\.to\.user



Destination user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodeNames



A list of node names managed by Noxa\. Due to the architecture of Noxa,
noxa modules might unwillingly create new nodes, this list contains the name of all nodes
that are currently managed by Noxa\. Noxa modules can check this list to see if a node
was created by themselves\.

````
  The user must set this to the listOf all nodes they want to manage, otherwise if you
  don't care, set this to `attrNames config.nodes`.
````



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## nodes



A set of nixos hosts managed by Noxa\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/default\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/default.nix)



## nodes\.\<name>\.build\.toplevel



Build this node’s configuration into a NixOS system package\.

Alias to ` config.system.build.toplevel `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## nodes\.\<name>\.build\.vm



Build this node’s configuration into a VM testing package\.

Alias to ` config.system.build.vm `\.



*Type:*
package *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/build\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/build.nix)



## nodes\.\<name>\.nixpkgs



The nixpkgs version to use when building this node\.

By default, if not explicitly set, it uses the same version than the Noxa flake itself\.



*Type:*
absolute path



*Default:*
` "<nixpkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.options



The contents of the options defined by the nixpkgs module for this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<options>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.pkgs



The pkgs set with overlays and for the target system of this node\.



*Type:*
raw value *(read only)*



*Default:*
` "<pkgs>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/nixpkgs\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/nixpkgs.nix)



## nodes\.\<name>\.reachable\.allowHostConfiguration



Allow the host to configure its own reachable addresses\. If set to false, values can only be set on the Noxa module level\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.reachable\.internet



List of external IP addresses this host is reachable at via using a public IP address\.



*Type:*
list of (IPv4 address or IPv6 address)



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.reachable\.wireguardNetwork



List of IP addresses this host is reachable at via WireGuard (specified via name)\.



*Type:*
attribute set of list of (IPv4 address or IPv6 address)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/info\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/info.nix)



## nodes\.\<name>\.specialArgs



Special arguments passed to the host modules\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/configuration\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/configuration.nix)



## nodes\.\<name>\.ssh\.grants



Grant SSH access from from node users to to node users\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.commands



Function that evaluates to a list of commands the user is allowed to execute on the target node\. If empty, all commands are allowed\.

This function will be called with the pkgs\.callPackage function taken from the target node\.



*Type:*
function that evaluates to a(n) list of ((submodule) or package convertible to it)



*Default:*
` <function> `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.aliases



The SSH command that is requested by the user, mapping to this command\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.command



The command to allow\.



*Type:*
string or package convertible to it

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.passParameters



Whether to pass any parameters given by the user to the command\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.extraConnectionOptions



Additional SSH connection options to use when connecting to the target node\.

View man SSH(8) - AUTHORIZED_KEYS



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.from



Source user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.name



Alias name under which the user can ` ssh {alias} ` to the target\.



*Type:*
string



*Default:*
` "<name>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.agentForwarding



Apply the “agent-forwarding” option to this SSH key, allowing SSH agent forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.listen



Apply the “permitlisten” option to this SSH key, remote listening and
forwarding of ports to local ports\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.open



Apply the “permitopen” option to this SSH key, allowing to open
specific host:port combinations\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.pty



Apply the “pty” option to this SSH key, allowing to allocate a pseudo-terminal\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.restrict



Apply the “restrict” option to this SSH key, disabling every feature
except executing commands\. Disabling this option, will circumvent all
other options set via \.options \.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.options\.x11Forwarding



Apply the “x11-forwarding” option to this SSH key, allowing X11 forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.resolvedCommands



The resolved commands after evaluating the ` commands ` function\.



*Type:*
(list of ((submodule) or package convertible to it)) or string *(read only)*

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.showAvailableCommands



If set to true, when the user tries to execute an unauthorized command,
the list of available commands will be shown\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.sshGenKeyType



When generating SSH keys use this key type\.



*Type:*
one of “ed25519”, “rsa”



*Default:*
` "ed25519" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to



Destination node and user\.



*Type:*
submodule



*Default:*
` "<to>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to\.hostname



Hostname or IP address of the target node\.



*Type:*
string



*Default:*
` "<to.node>" `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to\.node



Destination node name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to\.port



SSH port of the target node\.



*Type:*
signed integer



*Default:*
` 22 `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to\.sshFingerprint



Expected SSH host key fingerprint of the destination node\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)



## nodes\.\<name>\.ssh\.grants\.\<name>\.to\.user



Destination user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/noxa/nodes/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes/ssh.nix)


