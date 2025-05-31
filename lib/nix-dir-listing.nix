{
  nixpkgs,
  lib ? nixpkgs.lib,
  ...
}:
with lib; with builtins;
rec {

  /**
      Generates a list of all `*.nix` files and `<name>/default.nix` files in the specified directory.

      # Inputs
      `path` : The directory to search for Nix files.

      # Output
      A list of paths to the found files.

      # Type
      ```
      Path -> [ Path ]
      ```
  */
  list-nix-directory =
    path:
    let
      entries = readDir path;
      files = attrNames (filterAttrs (name: type: type == "regular") entries);
      directories = attrNames (filterAttrs (name: type: type == "directory") entries);

      filterNixFiles = files: filter (name: match ".*?\.nix$" name != null) files;
      nixFilesRoot = map (name: path + "/${name}") (filter (f: f != "default.nix") (filterNixFiles files));

      potentialNixFolders = map (dir: path + "/${dir}/default.nix") directories;
      nixFolders = filter (file: builtins.pathExists file) potentialNixFolders;
    in
    (nixFilesRoot ++ nixFolders);

  /**
      Generates a list of all `*.nix` files in the specified directory and its subdirectories; if a `path` is provided.
      If a `[ Any ]` is provided, the input will be returned as is.
      
      # Inputs
      `path` : The directory to search for Nix files.
      
      # Output
      A list of paths in a directory or the input list of paths.

      # Type
      ```
      Path -> [ Path ]
      [ Any ] -> [ Any ]
      ```
      */
  expand-path-list = paths: 
    if typeOf paths == "path" then
      list-nix-directory paths
    else if typeOf paths == "list" then
      paths
    else
      throw "expand-path-list expects a path or a list of paths";

}
