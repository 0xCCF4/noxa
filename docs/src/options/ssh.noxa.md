## ssh\.debug

Enable debug logging for the SSH module\.



*Type:*
anything *(read only)*

*Declared by:*
 - [noxa/modules/noxa/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/ssh.nix)



## ssh\.grant



Grant SSH access from from node users to to node users\.



*Type:*
attribute set of attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/ssh.nix)



## ssh\.grant\.\<name>\.\<name>\.accessTo



List of users on the to node to grant access to\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [noxa/modules/noxa/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/ssh.nix)



## ssh\.grant\.\<name>\.\<name>\.accessTo\.\<name>\.users



List of users on the to node to grant access to\.



*Type:*
list of string

*Declared by:*
 - [noxa/modules/noxa/ssh\.nix](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/ssh.nix)


