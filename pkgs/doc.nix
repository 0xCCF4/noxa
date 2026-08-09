{ self
, lib
, pkgs
, runCommand
, mdbook
, nixosOptionsDoc
, nixpkgs
, ...
}@inputs:
with lib; with builtins;
let
  makeOptionsDoc =
    module:
    let
      eval = (
        (evalModules {
          modules = [
            module
            (
              { lib, ... }:
              {
                # Provide `pkgs` arg to all modules
                config._module = {
                  args.pkgs = pkgs;
                  args.self = { nixosConfigurations = { }; };
                  check = false;
                };
                # Mock the real NixOS `networking.hostName` option: modules derive
                # their own host identity from it instead of taking a `noxaHost` arg.
                options.networking.hostName = mkOption {
                  type = types.str;
                  default = "<noxa-host-id>";
                  description = "Mocked for documentation purposes.";
                };
                # Hide NixOS `_module.args` from nixosOptionsDoc to remain specific to noxa
                options._module.args = mkOption {
                  internal = true;
                };
              }
            )
          ];
          specialArgs = inputs // {
            noxa = self // {
              lib = self.lib // {
                net = inputs.nix-net-lib.lib;
              };
              inherit nixpkgs;
              managedNodes = [ ];
              wireguard = { };
              __buildDocs = true;
            };
            agenix-rekey = { nixosModules.default = { }; };
            agenix = { nixosModules.default = { }; };
          };
        })
      );
    in
    nixosOptionsDoc {
      options = eval.options;

      transformOptions =
        opt:
        opt
        // {
          declarations = map
            (
              decl:
              let
                root = toString ../.;
                declStr = toString decl;
                declPath = removePrefix root decl;
              in
              if
                hasPrefix root declStr
              # Rewrite links from ../. in the /nix/store to the source on Github
              then
                {
                  name = "noxa${declPath}";
                  url = "https://github.com/0xCCF4/noxa/tree/main${declPath}";
                }
              else
                decl
            )
            opt.declarations;
        };
    };

  nixosPaths = self.lib.nixDirectoryToAttr' ../modules/nixos;

  # Options contributed by `flakeModules.default` (modules/flake-parts) are flake-parts
  # options, not NixOS options, and are not covered by this NixOS-module-oriented doc
  # generator. Document them by hand in docs/src/modules.md instead.
  groups = attrsets.mapAttrs' (name: value: lib.attrsets.nameValuePair (name + ".nixos") value) nixosPaths;

  documentation = attrsets.mapAttrs (name: module: makeOptionsDoc module) groups;

  docCommands = attrsets.mapAttrsToList
    (name: value:
      "cp ${value.optionsCommonMark} docs/src/options/${name}.md"
    )
    documentation;

in
runCommand "noxa.nix-doc"
{
  nativeBuildInputs = [ mdbook ];
}
  ''
    set -euo pipefail
    cp -r ${../docs} docs
    chmod -R u+w docs/src
    
    ${concatStringsSep "\n" docCommands}
    
    ${mdbook}/bin/mdbook build -d $out docs
    cp -r docs/ $out/docs
  ''
