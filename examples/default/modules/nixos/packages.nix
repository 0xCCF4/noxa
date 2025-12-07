{ config, lib, pkgs, ... }: with lib; {
  config = {
    # packages on all systems
    environment.systemPackages = with pkgs; [
      # ...
    ];
  };
}
