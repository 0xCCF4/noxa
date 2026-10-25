# Main noxa configuration file
# This is the central configuration file for your multi-host NixOS setup.
#
# Hosts live in the `./hosts` directory. ez-configs discovers each file there
# as a host, using the file name as the host name. To add a new host, add a
# new file to `./hosts`. `./modules/default.nix` applies to every host.
{ inputs, self, config, ... }: {
  # Use the flake's own store path, not a `./.` path literal. Nix copies a path
  # literal to the store again when you interpolate it. In read-only mode (for
  # example `nix flake check`) that copy does not exist, so evaluation fails with
  # "path ... is not valid".
  ezConfigs.root = self.outPath;
  # Derived from `ezConfigs.root` (not a bare `./hosts` literal) so hosts stay in the
  # same store copy as `../hardware` and `../secrets`. A standalone path literal to
  # just the `hosts` directory would copy it to the store in isolation, breaking any
  # `../` references inside it.
  ezConfigs.nixos.configurationsDirectory = "${config.ezConfigs.root}/hosts";
  ezConfigs.nixos.modulesDirectory = "${config.ezConfigs.root}/modules";

  ezConfigs.nixos.specialArgs = {
    inherit (inputs) home-manager agenix agenix-rekey;
  };

  # Allow interoperability with "standard" nixos build tools
  # (`self.nixosConfigurations.<host>` is set by ez-configs already)

  # Agenix rekey module configuration
  # See the wiki <https://0xccf4.github.io/noxa/modules/secrets.html> for more information
  flake.agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nixosConfigurations = self.nixosConfigurations;
  };
}
