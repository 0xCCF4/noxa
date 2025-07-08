/**
   Since very commonly you would like to assign different device addresses
   to different peers, while keeping the same network address,
   this module provides a simple way to do so.
   It allows you to specify a `deviceNumber` for each interface,
   which will be used to generate the device address
   based on the network address.
 */
{ pkgs
, inputs
, config
, lib
, noxa
, ...
}: with lib; with builtins; with types; with noxa.lib.net.types;
let
  cfg = config.noxa.wireguard;
in
{
  options.noxa.wireguard.interfaces = mkOption {
    type = lazyAttrsOf (submodule (submod: {
      options = {
        deviceNumber = mkOption {
          type = nullOr int;
          default = null;
          description = ''
            If set, a new address will be assigned to the peer with the following schema:

            The network prefix defined in `noxa.wireguard.interfaces.<name>.networkAddress` will be used as the base
            for the device address, and the value of `noxa.wireguard.interfaces.<name>.deviceNumber` will be used
            in the device part. For example, if the network prefix is `1.2.0.0/16` and the device number is `11`,
            the address added to the peer will be `1.2.0.11/32`.

            The device number might be a single number passed into the last component of the address.
          '';
          example = "3";
        };

        _deviceAddress = mkOption {
          type = nullOr ip;
          readOnly = true;
          description = ''
            The device address assigned to the peer, based on the network address and device number.
            This is automatically generated.
          '';
        };
      };

      config =
        let
          networkAddress = (noxa.lib.net.decompose submod.config.networkAddress).networkParts;
          updatedAddress = (lists.sublist 0 (length networkAddress - 1) networkAddress) ++ [ submod.config.deviceNumber ];
          deviceAddress = (noxa.lib.net.ip submod.config.networkAddress).composeStr updatedAddress 32;
        in
        {
          _deviceAddress = deviceAddress;
          deviceAddresses = [ submod.config._deviceAddress ];
        };
    }));
  };

  config = {
    assertions = mkMerge (map
      (name:
        let
          submod = cfg.interfaces.${name};
        in
        mkIf (submod.deviceNumber != null) [{
          assertion = noxa.lib.net.laysWithinSubnet submod._deviceAddress submod.networkAddress;
          message = "The device address ${submod._deviceAddress} must be part of the network ${submod.networkAddress}.";
        }])
      (attrNames cfg.interfaces));
  };
}
