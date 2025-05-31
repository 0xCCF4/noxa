{ nixpkgs
, lib ? nixpkgs.lib
, ...
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
  nixDirectoryToList =
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
      Generates a set of all `<name>.nix` files and `<name>/default.nix` files in the specified directory.

      # Inputs
      `path` : The directory to search for Nix files.

      # Output
      A set of paths to the found files, with the file names as keys.
      ```
      {
        "<name1>" = <path>; # e.g. <name1>.nix
        "<name2>" = <path>; # e.g. <name2>/default.nix
        ...
      }
      ```

      # Type
      ```
      Path -> { <name> : Path }
      ```

      # Note
      If a file `<name>.nix` and a directory `<name>/default.nix` exist the file will be preferred.
      */
  nixDirectoryToAttr =
    path:
    let
      entries = readDir path;
      files = attrNames (filterAttrs (name: type: type == "regular") entries);
      directories = attrNames (filterAttrs (name: type: type == "directory") entries);

      filterNixFiles = files: filter (name: match ".*?\.nix$" name != null) files;
      nixFilesRoot = filter (f: f != "default.nix") (filterNixFiles files);

      # Build attribute set from .nix files (excluding default.nix)
      fileAttrs = listToAttrs (map
        (name: {
          inherit name;
          value = path + "/${name}";
        })
        nixFilesRoot);

      # Build attribute set from directories with default.nix, but only if not shadowed by a .nix file
      dirAttrs = listToAttrs (map
        (dir: {
          name = dir;
          value = path + "/${dir}/default.nix";
        })
        (filter (dir: builtins.pathExists (path + "/${dir}/default.nix")) directories));
    in
    dirAttrs // fileAttrs;


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
  expandNixPathList = paths:
    if typeOf paths == "path" then
      nixDirectoryToList paths
    else if typeOf paths == "list" then
      paths
    else
      throw "expand-path-list expects a path or a list of paths";

}
