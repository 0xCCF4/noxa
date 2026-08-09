# ez-configs imports this into every host by default.
#
# Local modules under `../modules/nixos` are imported directly (via
# nixDirectoryToAttr', not through `self.nixosModules.default`). Reading a
# `self.*` flake output from inside a module that's itself part of building
# `self.nixosConfigurations` risks a self-referential forcing loop in
# flake-parts' `config.flake` merge; importing the files directly avoids it.
#
# The overlay reads `../packages` directly with `callPackage`, not through
# `self.packages`, for the same reason: `self.packages.<system>` also
# contains `knownHosts`/`allNixosConfigs` (see parts/knownHosts.nix,
# parts/allNixosConfigs.nix), both of which read `self.nixosConfigurations`.
{ lib, inputs, ... }: with lib; let
  ownNixosModules = attrValues (filterAttrs (name: value: name != "default") (inputs.noxa.lib.nixDirectoryToAttr' ../modules/nixos));
  ownPackages = filterAttrs (name: value: name != "default") (inputs.noxa.lib.nixDirectoryToAttr' ../packages);
in
{
  imports = ownNixosModules ++ [
    inputs.noxa.nixosModules.secrets
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.overlays = [
    (final: prev: mapAttrs (name: path: final.callPackage path { }) ownPackages)
  ];
}
