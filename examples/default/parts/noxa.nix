{ inputs, lib, self, config, ... }: with lib; {
  # Use the flake's own store path, not a `./..` path literal. Nix copies a path
  # literal to the store again when you interpolate it. In read-only mode (for
  # example `nix flake check`) that copy does not exist, so evaluation fails with
  # "path ... is not valid".
  ezConfigs.root = self.outPath;
  # Derived from `ezConfigs.root` (not a bare `./hosts` literal) so hosts stay in the
  # same store copy as `../hardware`. A standalone path literal to just the `hosts`
  # directory would copy it to the store in isolation, breaking `../` references
  # inside host files.
  ezConfigs.nixos.configurationsDirectory = "${config.ezConfigs.root}/hosts";

  ezConfigs.nixos.specialArgs = {
    # All these are available to every host that imports them. `inputs` itself
    # is included so it can safely be used inside a module's own `imports`
    # list too. A value only reachable via `_module.args` (not a genuine
    # specialArg) can't be referenced from `imports`, since `imports` is
    # resolved before `_module.args` contributions are collected.
    inherit inputs;

    inherit (inputs) nixos-hardware;
    inherit (inputs) agenix;
    inherit (inputs) agenix-rekey;
    inherit (inputs) home-manager;
    inherit (inputs) nixpkgs-stable;
    inherit (inputs.self) users;
  };

  # Agenix rekey module configuration
  flake.agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nixosConfigurations = filterAttrs (name: value: name != "iso") self.nixosConfigurations;
  };
}
