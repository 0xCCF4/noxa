noxa-inputs: { ... }@inputs:
{
  imports = noxa-inputs.self.lib.nixDirectoryToList ./.;

  config = {
    nixpkgs.overlays = [
      (inputs.nix-net-lib or noxa-inputs.nix-net-lib).overlays.default
    ];
  };
}
