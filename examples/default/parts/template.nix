{ inputs, lib, self, ... }: with lib;
{
  flake.templates.default = {
    description = "NixOS configuration template";
    path = ./..;
  };
}
