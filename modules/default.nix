noxa-inputs: {
  noxa-lib? noxa-inputs.self.lib.noxa-lib,
  ...
}:
{
  imports = noxa-lib.nixDirectoryToList ./.;

}
