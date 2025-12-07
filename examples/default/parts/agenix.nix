{ inputs, lib, self, ... }: with lib; with builtins;
{
  perSystem = { pkgs, system, self', ... }: {
    packages.agenix-rekey = inputs.agenix-rekey.packages."${system}".default;
  };
}
