# SSH Module

The SSH module automated the distribution of SSH host config between managed hosts.

By specifying which user on which node has access to which user on a different node, SSH configuration and authorized SSH keys can be generated and distributed automatically.

## Example

```nix
{...}: {
    config = {
        ssh.grant."sourceNodeName"."sourceNodeUser".
            accessTo."targetNodeName".users = [ "targetUser" ];
    };
};
```

Will grant `sourceNodeUser@sourceNodeName` SSH access to the machine `targetUser@targetNodeName` by
1. Generating a SSH keypair.
2. The private key part will be placed inside the sourceNode's agenix keystore using the [NixOS Secrets](./secrets.md) module.
3. The public key part will be registered as an authorizedKey on the target node for the targetUser.

Each step is configurable, e.g. instead of generating a custom keypair a local path may be used, an SSH command forced, ... . Reference the [SSH module option's reference](../options/ssh.noxa.md) for a detailed list of options.