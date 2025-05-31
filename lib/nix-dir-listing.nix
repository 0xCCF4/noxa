{
  nixpkgs,
  lib ? nixpkgs.lib,
  ...
}:
with lib; with builtins;
{

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
}
