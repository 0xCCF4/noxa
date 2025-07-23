{ lib, config, noxaConfig, ... }: with lib; with builtins; {
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

  config =
    let
      assertWarnCheck = lib.asserts.checkAssertWarn
        (noxaConfig.assertions)
        (noxaConfig.warnings)
        config.configuration.system.build;
    in
    {
      build.toplevel = assertWarnCheck.toplevel;
      build.vm = assertWarnCheck.vm;
    };
}
