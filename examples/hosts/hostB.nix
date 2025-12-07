{ ... }:
{
  configuration = { lib, config, ... }: {
    imports = [ ../hardware/vm.nix ];
  };
}
