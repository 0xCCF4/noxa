{ nixpkgs
, lib ? nixpkgs.lib
, ...
}:
with lib; with builtins;
rec {
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
  filesystem.baseNameWithoutExtension = val:
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


  /**
    Constructs a file path with a specified extension.
    The extension is replaced or added to the base name of the file.

    # Inputs
    `val` : The file name or path to which the extension will be added.
    `ext` : The extension to be added (without the leading dot).

    # Output
    A string representing the file path with the specified extension.
    
    # Type
    ```
    Path -> Path
    ```
    */
  filesystem.withExtension = val: ext:
    if pathIsDirectory val then
      val
    else
      val + "/../${filesystem.baseNameWithoutExtension val}.${ext}";

  /**
    Reads the content of a file at the given path.
    If the file does not exist, throws an error with the provided message.
    
    # Inputs
    `path` : The file path to read.
    `error` : The error message to throw if the file does not exist.
    
    # Output
    The content of the file as a string.
    
    # Type
    ```
    Path -> String -> String
    ```
    */
  filesystem.readFileWithError = path: error:
    if lib.filesystem.pathIsRegularFile path then
      readFile path
    else
      throw error;

}
