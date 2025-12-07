# Noxa Multi-Machine NixOS Setup

## Structure of this repository

The repository is structured as follows:
- `hardware/`: Hardware configuration files.
- `hosts/`: Host specific configuration files.
- `modules/nixos/`: OS configuration shared among all machines.
- `modules/home/`: User environment configuration shared among all machines.
- `modules/noxa/`: Infrastructure management configuration
- `parts/`: Scaffolding code for generating machine configurations.
- `secrets/`: Secrets deployed to the machines
- `users/`: User specific configuration files.

All these sub-directories are explained in more detail below.

### Hardware
`hardware/` contains hardware configuration files. Each physical setup has its own file. Several hosts might share the same hardware configuration (if they run on identical hardware).

Inside the hardware configuration file belong all settings that are:
- specific to the hardware (e.g. firmware settings)
- are needed to boot the machine on that hardware (e.g. disk layout)
- are shared among all hosts running on that hardware (e.g. kernel parameters)

### Hosts
`hosts/` contains host specific configuration files. Each host has its own file.

Inside the host configuration file belong all settings that are:
- specific to that particular host (e.g. network settings, users, installed services)
- not shared among other hosts (these settings should go into nixos modules)

Note: the name of the host configuration file is taken as the default hostname of the machine, note that it can be overridden inside the file itself.

If a host has a more complicated configuration, it can be split into multiple files inside a sub-directory named after the host. The main entry point is then `hosts/<hostname>/default.nix`.

A minimal host configuration file looks like this:
```nix
{ config, pkgs, ... }:
{
  imports = [
    ../hardware/<hardware>.nix
  ];

  config = {
    # After the first boot, set the host public key here to allow secret deployment
    # noxa.secrets.options.hostPubkey = "ssh-ed25519 PUBLIC_SSH_KEY_HERE";

    # Machine type: "server" or "workstation"
    mine.machineType = "workstation";

    # Users granted access to this machine
    mine.users = [
      "alice"
    ];

    # Admin users with sudo access
    mine.admins = [
      "bob"
    ];
  };
}
```

### Users
`users/` contains user specific configuration files. Each user has its own file. If a user's configuration is more complicated, it can be split into multiple files inside a sub-directory named after the user. The main entry point is then `users/<username>/default.nix`.

Inside the user configuration file belong all settings that are:
- specific to that particular user (e.g. SSH keys, password, home environment)
- not shared among other users (these settings should go into home modules)

A user configuration file looks like this:
```nix
{ ... }: {
  description = "Where does this user come from?";
  authorizedKeys = [
    "SSH PUB KEY HERE"
  ];
  hashedPassword = "Password hash here";
  # shell = "bash";
  # home = { ... }: { }; # home environment configuration
  # homeConfigOverwrite = { ... }: { }; # see below
  # trustedNixKeys = [ "KEY-HERE" ]; # applied if user is admin on a host
}
```

The password hash can be generated with `openssl passwd -6 -salt 'rounds=10000$someRngSalt'`` or equivalent tools.

> Adding a completely new user:
> Adjust the UID mapping in `users/_mapping.json by adding a new entry for the new user. Make sure that the UID is unique and does not conflict with existing or retired users.

When adding a new user to a host (via `mine.users`), the corresponding user will automatically be created on that host with the given password and SSH key access.

If you would like to have certain software available in the user's home environment, you can add it via the `home` attribute. The home attribute is essentially a Home Manager module <https://nix-community.github.io/home-manager/options.xhtml>. Since all software declared in `home` will run under the user's privileges (at least it should be according to Home Manager's design), it should be safe to let each user manage their own home environment/<name>.nix file without risking system integrity.

A minimal example (for the `home` attribute) adding some software to the user's home environment:
```nix
# Refer <https://search.nixos.org/packages> for a list of all available packages
home = { lib, config, nixosConfig, pkgs, ... }: with pkgs; with lib; {
    home.packages = [
      btop
      screen
    ];
};
```

Advanced: If your home configuration depends on the machine configuration, you might want to override the view of the machine configuration as seen by the home module. This can be done via the `homeConfigOverwrite` attribute.

### NixOS modules
`modules/nixos/` contains NixOS modules, aka. configuration shared among all machines.

Inside the NixOS modules belong all settings that are:
- shared among all machines (e.g. common services, security settings)
- settings that might be used on multiple hosts (in the future)
- not specific to a particular host (these settings should go into host configuration files)

We categorize machines into two types: workstations and servers:
- Workstations are used by users to do their daily research work. They have a graphical user interface and are used interactively.
- Servers provide services like hosting services, websites, or compute resources. They are used exclusively via network access.

Set via `mine.machineType` in the host configuration file.

According to this categorization, we provide default values for all settings (e.g. desktop environments will be installed by default on workstations, but not on servers).

All custom configuration options (that are declared for this this template) are exposed via the `mine` namespace, when presets differ between single machines.

Settings here are separated by topic. Settings regarding the font configuration are located in `modules/nixos/fonts.nix`, settings regarding the SSH server are located in `modules/nixos/ssh.nix`, etc.

Adding a new NixOS module:
1. Create a new file in `modules/nixos/`, e.g. `my-module.nix`.
2. Add the newly created module to git via `git add modules/nixos/my-module.nix`.

The file will now be automatically included in all machine configurations.

A list of all available configuration options can be found at <https://search.nixos.org/options>

### Home modules
`modules/home/` contains Home Manager modules, aka. user environment configuration shared among all machines.

Inside the Home modules belong all settings that are:
- shared among all users (e.g. common shell configuration, editor settings)
- settings that might be used by multiple users (in the future)
- not specific to a particular user (these settings should go into user configuration files)

Adding a new Home module:
1. Create a new file in `modules/home/`, e.g. `my-home-module.nix`.
2. Add the newly created module to git via `git add modules/home/my-home-module.nix`.

The file will now be automatically included in all user home configurations.

A list of all available Home Manager configuration options can be found at <https://nix-community.github.io/home-manager/options.xhtml>.

### Noxa modules
`modules/noxa/` contains Noxa modules, aka. infrastructure management configuration. We use the Noxa framework <https://github.com/0xCCF4/noxa> to manage our multi-host NixOS infrastructure.

Inside the Noxa modules belong all settings that are:
- settings that are not part of a particular host but shared among a group of hosts (e.g. setup of overlay networks)
- settings that belong to a single host are to be placed inside the host configuration files or nixos modules directory.

Adding a new Noxa module:
1. Create a new file in `modules/noxa/`, e.g. `my-noxa-module.nix`.
2. Add the newly created module to git via `git add modules/noxa/my-noxa-module.nix`.

The file will now be automatically included in the Noxa configuration.

A list of all available Noxa configuration options can be found at <https://0xccf4.github.io/noxa/>.

### Flake parts
`parts/` contains the scaffolding code for making the machine configurations work. You should
not need to change anything here but refer to the documentation here: <https://flake.parts/>.

### Network topology
`topology/` contains the code to draw the network topology of our infrastructure.

Refer to the documentation of <https://oddlama.github.io/nix-topology/intro.html> for more information.

### Secrets
`secrets/` contains secrets deployed to the machines. The secrets are deployed to git encrypted via age,
decrypted on the target machines via their ssh host key pair.

When adding new secrets, you may create and edit them using the following commands:
```bash
nix run .#agenix-rekey -- generate # to generate new random secrets

nix run .#agenix-rekey -- agenix edit # to edit existing secrets/create new ones

nix run .#agenix-rekey -- agenix rekey # to encrypt the secrets with the target's key
```

See <https://github.com/oddlama/agenix-rekey> and <https://0xccf4.github.io/noxa/> for additional information.

## Inspecting the current configuration of a machine
You can inspect the current configuration of a machine by running:
```bash
nix run nixpkgs#nix-inspect -- --expr 'builtins.getFlake "path to this folder"'
```

## FAQ
You added a new file but it seems to be ignored by nix eval, e.g., you add a new host configuration file but the new host seems to be missing in the flake output.

> Make sure that you added the new file to git, e.g. via `git add hosts/new-host.nix`. The template makes use of `builtins.readDir` to automatically import files in e.g. `hosts/` directory, which only returns files tracked by git.

## Contributing
Feel free to contribute to this (template on <https://github.com/0xCCF4/noxa/>) via merge requests when you change or add something useful to either your own user, machine, or shared configuration.
