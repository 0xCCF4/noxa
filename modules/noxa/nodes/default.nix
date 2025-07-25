{ noxa, config, options, lib, specialArgs, ... }: with lib; with builtins; let
  parts = (noxa.lib.nixDirectoryToList ./.) ++ [ (noxa.nixpkgs + "/nixos/modules/misc/assertions.nix") ];

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

    nodeNames = mkOption {
      description = "A list of node names managed by Noxa. Due to the architecture of Noxa,
      noxa modules might unwillingly create new nodes, this list contains the name of all nodes
      that are currently managed by Noxa. Noxa modules can check this list to see if a node
      was created by themselves.
      
      The user must set this to the listOf all nodes they want to manage, otherwise if you
      don't care, set this to `attrNames config.nodes`.";
      default = [ ];
      type = listOf str;
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

    assertions = with noxa.lib.ansi; mkMerge (attrsets.mapAttrsToList
      (
        name: node: [{
          message = "${fgYellow}Node ${fgGreen}'${name}'${fgYellow} is not defined in ${fgGreen}config.nodes${fgYellow}.${default}";
          assertion = elem name config.nodeNames;
        }] ++ node.assertions
      )
      config.nodes);

    warnings = mkMerge (attrsets.mapAttrsToList (name: node: node.warnings) config.nodes);
  };
}
