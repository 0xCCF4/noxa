## ssh\.grants

Grant SSH access from from node users to to node users\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.commands



Function that evaluates to a list of commands the user is allowed to execute on the target node\. If empty, all commands are allowed\.

This function will be called with the pkgs\.callPackage function taken from the target node\.



*Type:*
function that evaluates to a(n) list of ((submodule) or package convertible to it)



*Default:*
` <function> `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.aliases



The SSH command that is requested by the user, mapping to this command\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.command



The command to allow\.



*Type:*
string or package convertible to it

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.commands\.\<function body>\.\*\.passParameters



Whether to pass any parameters given by the user to the command\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.extraConnectionOptions



Additional SSH connection options to use when connecting to the target node\.

View man SSH(8) - AUTHORIZED_KEYS



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.from



Source user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.name



Alias name under which the user can ` ssh {alias} ` to the target\.



*Type:*
string



*Default:*
` "<name>" `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.agentForwarding



Apply the “agent-forwarding” option to this SSH key, allowing SSH agent forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.listen



Apply the “permitlisten” option to this SSH key, remote listening and
forwarding of ports to local ports\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.open



Apply the “permitopen” option to this SSH key, allowing to open
specific host:port combinations\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.pty



Apply the “pty” option to this SSH key, allowing to allocate a pseudo-terminal\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.restrict



Apply the “restrict” option to this SSH key, disabling every feature
except executing commands\. Disabling this option, will circumvent all
other options set via \.options \.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.options\.x11Forwarding



Apply the “x11-forwarding” option to this SSH key, allowing X11 forwarding\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.resolvedCommands



The resolved commands after evaluating the ` commands ` function\.



*Type:*
(list of ((submodule) or package convertible to it)) or string *(read only)*

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.showAvailableCommands



If set to true, when the user tries to execute an unauthorized command,
the list of available commands will be shown\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.sshGenKeyType



When generating SSH keys use this key type\.



*Type:*
one of “ed25519”, “rsa”



*Default:*
` "ed25519" `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to



Destination node and user\.



*Type:*
submodule



*Default:*
` "<to>" `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to\.hostname



Hostname or IP address of the target node\.

Multiple addresses may be specified by providing a executable
each that when exiting with code 0 selects the corresponding address,
see the example value\.



*Type:*
string or attribute set of (submodule)



*Default:*
` "<to.node>" `



*Example:*

```
{
  local = {
    command = "ping -c 1 -W 1 192.168.0.55 > /dev/null";
    host = "192.168.0.55";
    priority = 10;
  };
  public = {
    command = "true";
    host = "host.example.com";
    priority = 20;
  };
}
```

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to\.node



Destination node name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to\.port



SSH port of the target node\.



*Type:*
signed integer



*Default:*
` 22 `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to\.sshFingerprint



Expected SSH host key fingerprint of the destination node\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)



## ssh\.grants\.\<name>\.to\.user



Destination user name\.



*Type:*
string

*Declared by:*
 - [noxa/modules/nixos/ssh/options\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/nixos/ssh/options.nix)


