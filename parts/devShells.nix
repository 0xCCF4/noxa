{ inputs, self, ... }: {
  perSystem = { pkgs, system, ... }: {
    devShells = import ../shells (inputs // { inherit self pkgs system; });
  };
}
