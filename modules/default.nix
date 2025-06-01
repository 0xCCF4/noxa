noxa-inputs: { noxa-lib ? noxa-inputs.self.lib
             , ...
             }:
{
  imports = noxa-lib.nixDirectoryToList ./.;

}
