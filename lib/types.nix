{ nixpkgs
, lib ? nixpkgs.lib
, ...
}:
with lib; with builtins;
# Copied and adapted from https://github.com/NixOS/nixpkgs/blob/master/lib/types.nix
let
  elemTypeFunctor =
    name:
    { elemType, ... }@payload:
    {
      inherit name payload;
      wrappedDeprecationMessage = makeWrappedDeprecationMessage payload;
      type = outer_types.types.${name};
      binOp =
        a: b:
        let
          merged = a.elemType.typeMerge b.elemType.functor;
        in
        if merged == null then null else { elemType = merged; };
    };
in
rec {
  types.uniqueListOf =
    elemType:
    mkOptionType rec {
      name = "uniqueListOf";
      description = "unique list of ${
            optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
      descriptionClass = "composite";
      check = x: isList x && (length x == length (unique x));
      merge =
        loc: defs:
        map (x: x.value) (
          filter (x: x ? value) (
            lists.unique (concatLists (
              imap1
                (
                  n: def:
                  imap1
                    (
                      m: def':
                      (mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
                        {
                          inherit (def) file;
                          value = def';
                        }
                      ]).optionalValue
                    )
                    def.value
                )
                defs
            ))
          )
        );
      emptyValue = {
        value = [ ];
      };
      getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
      getSubModules = elemType.getSubModules;
      substSubModules = m: uniqueListOf (elemType.substSubModules m);
      functor = (elemTypeFunctor name { inherit elemType; }) // {
        type = payload: types.uniqueListOf payload.elemType;
      };
      nestedTypes.elemType = elemType;
    };
}
