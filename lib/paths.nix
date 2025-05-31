{
  nixpkgs,
  lib ? nixpkgs.lib,
  ...
}:
with lib; with builtins;
{
    /**
    Extracts the base name of a file without its extension.
    If the file has multiple extensions, only the last extension is removed.
    If a directory is provided, its basename will be returned as is.

    # Inputs
    `name` : The file name from which to extract the base name.

    # Output
    The base name of the file without its extension.

    # Type
    ```
    String | Path -> String
    ```
    */
    baseNameWithoutExtension = val:
      let
        isPath = typeOf val == "path";
        isDirectory = if isPath then (pathIsDirectory val) else false;

        baseName = baseNameOf val;
        components = splitString "." baseName;
      in
        if isDirectory then
            baseName
        else if length components > 1 then
            concatStringsSep "." (take (length components - 1) components)
        else
            baseName;
}