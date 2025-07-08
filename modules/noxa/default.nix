{ noxa, ... }: with builtins; {
  imports = noxa.lib.nixDirectoryToList ./.;
}
