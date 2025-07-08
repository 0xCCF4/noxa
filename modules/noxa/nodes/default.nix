{ noxa, config, options, lib, specialArgs, ... }: with lib; with builtins; let
  parts = noxa.lib.nixDirectoryToList ./.;

  noxaConfigArg = {
    _module.args = {
      noxaConfig = config;
    };
  };

  submoduleInheritSpecialArgs = modules:
    types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = toList modules;
      inherit specialArgs;
    };
in
{
  options = with types; {
    nodes = mkOption {
      description = "A set of nixos hosts managed by Noxa.";
      default = { };
      type = let x = options; in attrsOf (submoduleInheritSpecialArgs (options.defaults.type.functor.payload.modules ++ options.defaults.definitions ++ [ noxaConfigArg ]));
    };

    defaults = mkOption {
      description = "Default options applied to all nodes.";
      default = { };
      type = submoduleInheritSpecialArgs parts;
    };
  };

  config = {
    _module.args = {
      noxaConfig = config.noxa;
    };

    defaults.configuration.imports = [
      ({ ... }: {
        _module.args = {
          noxaConfig = throw "TEST";
        };
      })
    ];
  };
}
