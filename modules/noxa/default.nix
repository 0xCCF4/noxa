{ noxa, ... }: with builtins; {
  imports = (noxa.lib.nixDirectoryToList ./.) ++ [
    (noxa.nixpkgs + "/nixos/modules/misc/assertions.nix")
  ];
}
