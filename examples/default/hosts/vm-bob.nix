{ config, lib, pkgs, users, noxa, ... }: with builtins; with lib;
{
  imports = [
    ../hardware/vm.nix
  ];

  config = {
    mine.machineType = "server";

    # noxa.secrets.options.hostPubkey = "...";

    mine.admins = [
      "bob"
    ];
  };
}
