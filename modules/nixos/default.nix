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
    Cross-host SSH access management module
    */
  ssh = { ... }: {
    imports = [ secrets ./ssh ];
  };

  /**
    Experimental overlay module used by nixos-instantiate
    */
  overlay = { ... }: {
    imports = [ ./overlay.nix ];
  };
}

