{ inputs, lib, self, ... }: with lib;
{
  perSystem = { pkgs, system, ... }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        inputs.agenix-rekey.packages.${system}.default
        git
        rage
      ];
    };
  };
}
