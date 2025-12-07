{ ... }: {
  description = "Bob";
  authorizedKeys = [
    # SSH public keys for Bob
  ];
  #hashedPassword = "...";
  home = { lib, config, nixosConfig, pkgs, ... }: with pkgs; with lib; {
    # Home manager module for Bob
  };
  trustedNixKeys = [
    # nix build keys, added to a system if user is set as admin
  ];
  shell = "bash";
  homeConfigOverwrite = { config, ... }: {
    # ...
  };
}
