{ lib, config, ... }: with lib; with builtins; {
  options = with types; {
    build.toplevel = mkOption {
      type = package;
      description = ''
        Build this node's configuration into a NixOS system package.
        
        Alias to `config.system.build.toplevel`.
      '';
      readOnly = true;
    };
    build.vm = mkOption {
      type = package;
      description = ''
        Build this node's configuration into a VM testing package.

        Alias to `config.system.build.vm`.
      '';
      readOnly = true;
    };
  };

  config = {
    build.toplevel = config.configuration.system.build.toplevel;
    build.vm = config.configuration.system.build.vm;
  };
}
