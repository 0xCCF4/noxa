{ self
, lib
, pkgs
, runCommand
, mdbook
, nixosOptionsDoc
, ...
}@inputs:
with lib; with builtins; 
let
  makeOptionsDoc =
    module:
    nixosOptionsDoc {
      inherit
        ((evalModules {
          modules = [
            module
            (
              { lib, ... }:
              {
                # Provide `pkgs` arg to all modules
                config._module = {
                  args.pkgs = pkgs;
                  check = false;
                };
                # Hide NixOS `_module.args` from nixosOptionsDoc to remain specific to noxa
                options._module.args = mkOption {
                  internal = true;
                };
              }
            )
          ];
          specialArgs = inputs // {
            noxa = {
              net = inputs.nix-net-lib.lib;
              lib = self.lib;
              nixosConfigurations = { };
            };
            agenix-rekey = {nixosModules.default = {};};
            agenix = {nixosModules.default = {};};
          };
        }))
        options
        ;

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

  groups = {
    secrets = ../modules/secrets;
    wireguard = ../modules/wireguard ;
    overlay = ../modules/overlay.nix;
  };

  documentation = attrsets.mapAttrs (name: module: makeOptionsDoc module) groups;

in
runCommand "noxa.nix-doc"
{
  nativeBuildInputs = [ mdbook ];
}
  ''
    set -euo pipefail
    cp -r ${../docs} docs
    chmod -R u+w docs/src
    
    cp ${documentation.secrets.optionsCommonMark} docs/src/secrets.md
    cp ${documentation.wireguard.optionsCommonMark} docs/src/wireguard.md
    cp ${documentation.overlay.optionsCommonMark} docs/src/overlay.md
    
    ${mdbook}/bin/mdbook build -d $out docs
    cp -r docs/ $out/docs
  ''
