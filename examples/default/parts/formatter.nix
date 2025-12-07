{ inputs, lib, self, ... }: with lib;
{
  perSystem = { pkgs, system, ... }: {
    formatter = pkgs.nixpkgs-fmt;
  };
}
