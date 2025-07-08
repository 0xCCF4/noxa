{ self
, nixpkgs
, lib ? nixpkgs.lib
, noxa ? self
, nix-net-lib
, ...
}:
with lib; with lib.filesystem; with lib.attrsets; with builtins;
let
in
{
  /**
      Instantiates a Noxa NixOS configuration.

      # Inputs
      A set of arguments passed to `lib.evalModules` to instantiate a Noxa configuration.
        ```nix
        {
          modules = [ <noxaModule> ... ];
        }
        ```

      # Output
      A Noxa NixOS configuration
      ```
  */
  noxa-instantiate = args: nixpkgs.lib.evalModules {
    class = if args ? "class" then (with noxa.lib.ansi; trace "${fgPurple}Warning: You are overwriting the class argument to ${fgCyan+toString args.class+fgPurple}. Hopefully you know what you are doing...${reset}" args.class) else "noxa";
    modules = args.modules ++ [
      ../modules/noxa
    ];

    specialArgs = (args.specialArgs or { }) // {
      noxa = ((args.specialArgs or { }).noxa or noxa) // {
        inherit nixpkgs;
        nixosModules = noxa.nixosModules;
        noxaModules = noxa.noxaModules;
        lib = (args.specialArgs.noxa or noxa).lib // {
          net = nix-net-lib.lib;
        };
      };
    } // (removeAttrs args [ "modules" "class" "specialArgs" ]);
  };
}
