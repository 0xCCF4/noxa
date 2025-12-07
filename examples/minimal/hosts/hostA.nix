# This is an exemplary nixos configuration for hostA
# Inside `configuration`, you can as usual define your nixos configuration for this host
# 
# We have imported the `hardware/vm.nix` hardware configuration, which is a
# hardware configuration for our (noxa's) automated testing VMs.
# You may want to change this to your own hardware configuration (which you suggest
# to put into `hardware/...)
{ ... }:
{
  configuration = { lib, config, ... }: {
    imports = [ ../hardware/vm.nix ];

    noxa.secrets.def = [{
      module = "test";
      ident = "dummy-key";
      generator.script = "dummy";
      generator.tags = [ "example" ];
    }];
  };
}
