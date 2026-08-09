{ inputs, self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.doc = pkgs.callPackage ../pkgs/doc.nix (inputs // { inherit self; });
    packages.prebuilt = pkgs.callPackage ../pkgs/prebuilt.nix (inputs // { inherit self; });
  };
}
