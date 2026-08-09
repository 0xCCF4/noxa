# This is an exemplary nixos configuration for hostA.
#
# We import the `hardware/vm.nix` hardware configuration, a
# hardware configuration for Noxa's automated testing VMs.
# Replace this with your own hardware configuration (put it under `hardware/`).
{ ... }: {
  imports = [ ../hardware/vm.nix ];

  noxa.secrets.def = [{
    module = "test";
    ident = "dummy-key";
    generator.script = "dummy";
    generator.tags = [ "example" ];
  }];
}
