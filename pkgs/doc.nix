{ self
, lib
, pkgs
, runCommand
, mdbook
, nixosOptionsDoc
, ...
}@inputs:

let
  makeOptionsDoc =
    module:
    nixosOptionsDoc {
      inherit
        ((lib.evalModules {
          modules = [
            module
            (
              { lib, ... }:
              {
                # Provide `pkgs` arg to all modules
                config._module = {
                  args = inputs;
                  check = false;
                };
                # Hide NixOS `_module.args` from nixosOptionsDoc to remain specific to noxa
                options._module.args = lib.mkOption {
                  internal = true;
                };
              }
            )
          ];
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
                declPath = lib.removePrefix root decl;
              in
              if
                lib.hasPrefix root declStr
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

  optionsDocs = makeOptionsDoc (import ../modules inputs);

in
runCommand "noxa.nix-doc"
{
  nativeBuildInputs = [ mdbook ];
}
  ''
    cp -r ${../docs} docs
    chmod u+w docs/src
    cp ${optionsDocs.optionsCommonMark} docs/src/options.md
    ${mdbook}/bin/mdbook build -d $out docs
  ''
