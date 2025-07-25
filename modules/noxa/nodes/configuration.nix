{ lib, config, name, noxa, noxaConfig, agenix, agenix-rekey, ... }: with lib; with builtins; let

  evalConfig = import (config.nixpkgs + "/nixos/lib/eval-config.nix") {
    system = null;
    modules = [
      {
        _module.args = {
          inherit name;
          noxaHost = name;
          nodes = attrsets.mapAttrs (x: v: v.configuration) noxaConfig.nodes;
        };
      }
      noxa.nixosModules.default
    ];
    specialArgs = {
      inherit agenix;
      inherit agenix-rekey;
    } // config.specialArgs // {
      noxa = noxa // {
        nixpkgs = throw "Do not use the global nixpkgs of noxa. This is reserved for building the Noxa configuration.";
      };
    };
  };
in
{
  options = with types; {
    specialArgs = mkOption {
      type = attrsOf (types.anything);
      description = "Special arguments passed to the host modules.";
      default = { };
    };

    configuration = mkOption {
      type = evalConfig.type;
      description = "Nixos configuration for this node.";
    };
  };
}
