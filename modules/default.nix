inputs:
{
  noxa-lib ? inputs.self.lib.noxa-lib,
  ...
}:
{
  imports = noxa-lib.list-nix-directory ./.;

}
