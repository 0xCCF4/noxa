{ config, lib, noxa, ... }: with lib; {
  options.mine = with lib.types; {
    machineType = mkOption {
      type = enum [ "server" "workstation" ];
      description = ''
        Type of the machine.
                
        Used to preconfigure settings like desktop environment, services, etc.
      '';
    };
    isWorkstation = mkOption {
      type = types.bool;
      default = config.mine.machineType == "workstation";
      description = ''
        Whether this machine is a workstation.
      '';
      readOnly = true;
    };
    isServer = mkOption {
      type = types.bool;
      default = config.mine.machineType == "server";
      description = ''
        Whether this machine is a server.
      '';
      readOnly = true;
    };
  };
}
