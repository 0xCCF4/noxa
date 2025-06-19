noxa-inputs: rec {
  /**
     Default nixos module, including all features
  */
  default = { ... }: {
    imports = noxa-inputs.self.lib.nixDirectoryToList ./.;
  };

  /**
    Multi-host secrets management module
    */
  secrets = { ... }: {
    imports = [ ./secrets ];
  };

  /**
    Multi-host wireguard network configuration module
    */
  wireguard = { ... }: {
    imports = [ secrets ./wireguard ];
  };

  /**
    Experimental overlay module used by nixos-instantiate
    */
  overlay = { ... }: {
    imports = [ ./overlay.nix ];
  };
}

