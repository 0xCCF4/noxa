{ pkgs
, config
, lib
, noxa
, ...
}:
with lib; with builtins;
let
  toFileName = text: lib.strings.stringAsChars (char: if char == "-" || char == "_" || char == "." then "-" else char) text;

  interfaceOpts = self: {
    options = {
      networkAddress = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "The network IP addresses";
      };

      # dns = lib.mkOption {
      #   type = lib.types.listOf lib.types.str;
      #   default = [ ];
      #   description = "The DNS servers for the WireGuard interface";
      # };

      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Specifies whether to autostart the WireGuard interface and which IP version to use.";
      };

      backend = lib.mkOption {
        type = lib.types.enum [ "wireguard" "wg-quick" ];
        default = "wireguard";
        description = "The backend to use for WireGuard";
      };

      deviceAddresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "The device IP addresses";
      };

      listenPort = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "The port for WireGuard to listen for incoming connections";
      };

      addFirewallAllow = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Add firewall rule to allow traffic for listenPort";
      };

      listenAddress = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The address for WireGuard to listen for incoming connections";
      };

      remoteKeepAlive = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "The keep alive interval remote peers should use";
      };

      localKeepAlive = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "The keep alive interval this interface will use, if remoteKeepAlive is set, this will use the minimum of both";
      };

      isServer = lib.mkOption {
        type = lib.types.bool;
        default = self.config.listenAddress != null;
        description = "Specifies whether this peer is a server";
        readOnly = true;
      };

      additionalPeers = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "Additional peers to add to the WireGuard interface";
      };
    };
  };

  secretOpts = { ... }: {
    options = {
      presharedKeyFile = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "The pre-shared key file for WireGuard";
      };

      publicKey = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "The public key file for WireGuard";
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "The private key file for WireGuard";
      };
    };
  };

  allInterfaces = name: lib.filter (val: val.config != null) (lib.attrValues (lib.attrsets.genAttrs (builtins.attrNames self.nixosConfigurations)
    (hostname:
      let
        container = self.nixosConfigurations.${hostname}.config.modules.nixos.wireguard.interfaces;
        interface = if lib.attrsets.hasAttr "${name}" container then container."${name}" else null;
      in
      {
        host = "${hostname}";
        config = interface;
      })));

  otherInterfaces = name: lib.filter (interface: interface.host != config.networking.hostname) (allInterfaces name);

  architectureType = peers:
    let
      serverCount = builtins.length (lib.filter (peer: peer.config.isServer) peers);
    in
    if serverCount == 1 then
      "client-server"
    else if serverCount == 0 then
      "client"
    else if serverCount == builtins.length peers then
      "server-server"
    else
      "server-server-client";

  getServer = peers:
    let
      server = lib.filter (peer: peer.config.isServer) peers;
    in
    if builtins.length server == 1 then
      builtins.head server
    else
      null;

  wireguardDefinition = { name, me, allInterfaces }:
    let
      otherPeers = lib.filter (peer: peer.host != me.host) allInterfaces;
      server = (if me.config.isServer then me else (getServer otherPeers));
      funcOrNull = func: a: b: if a != null && b != null then func a b else if a != null then a else b;
      funcOrMkIf = func: a: b: lib.mkIf (a == null && b == null) (func a b);

      mySecrets = config.modules.nixos.wireguard.secrets.${name};
      itsSecrets = peer: {
        publicKey = self.nixosConfigurations.${peer.host}.config.modules.nixos.wireguard.secrets.${name}.publicKey;
        presharedKeyFile = config.age.secrets."wg-${name}-${peer.host}-psk".path;
      };

      peers =
        if !me.config.isServer then
          ([{
            publicKey = (itsSecrets server).publicKey;
            presharedKeyFile = mySecrets.presharedKeyFile;
            persistentKeepalive = funcOrMkIf (funcOrNull lib.trivial.min) server.config.remoteKeepAlive me.config.localKeepAlive;
            endpoint = "${server.config.listenAddress}:${toString server.config.listenPort}";
            allowedIPs = me.config.networkAddress;
            name = lib.mkIf (me.config.backend == "wireguard") server.host;
          }] ++ me.config.additionalPeers)
        else
          ((lib.map
            (peer: {
              publicKey = (itsSecrets peer).publicKey;
              presharedKeyFile = (itsSecrets peer).presharedKeyFile;
              persistentKeepalive = funcOrMkIf (funcOrNull lib.trivial.min) server.config.remoteKeepAlive me.config.localKeepAlive;
              allowedIPs = peer.config.deviceAddresses;
              name = lib.mkIf (me.config.backend == "wireguard") peer.host;
            })
            otherPeers) ++ me.config.additionalPeers)
      ;
    in
    {
      privateKeyFile = mySecrets.privateKeyFile;
      listenPort = me.config.listenPort;
      ips = me.config.deviceAddresses;
      inherit peers;
    };
in
with lib; with builtins; {
  options = {
    modules.nixos.wireguard = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable WireGuard module";
      };

      interfaces = mkOption {
        type = types.attrsOf (types.submodule interfaceOpts);
        default = { };
        description = "WireGuard interfaces";
      };

      secrets = mkOption {
        type = types.attrsOf (types.submodule secretOpts);
        default = { };
        description = "WireGuard secrets";
      };
    };
  };

  config = mkIf config.modules.nixos.wireguard.enable (noxa.lib.mkAssert (hasAttr config age) "The agenix module is required to use WireGuard with Noxa" {
    assertions = (lib.flatten (attrValues (
      mapAttrs
        (name: interface:
          let
            peers = allInterfaces name;
            architecture = architectureType peers;
          in
          [
            {
              assertion = inputs.settings.modules.agenix;
              message = "WG ${name} requires the agenix module";
            }
            {
              assertion = architecture == "client-server";
              message = "WG ${name} architecture must be client-server. It is: ${architecture}";
            }
            {
              assertion = builtins.pathExists (../../../secrets/hosts/${config.networking.hostName} + "/wg-${toFileName name}-key.pub");
              message = "WG ${name} public key file does not exist on ${config.networking.hostName}. Run `agenix generate`. Dont forget <git add>.";
            }
            {
              assertion = interface.isServer || builtins.length (builtins.filter (p: p.endpoint == null) interface.additionalPeers) == 0;
              message = "WG ${name} is a client and has additional peers without endpoint defined.";
            }
          ]
        )
        config.modules.nixos.wireguard.interfaces
    )));

    networking.wg-quick.interfaces = (lib.mapAttrs
      (name: interface:
        wireguardDefinition { me = { host = config.networking.hostName; config = interface; backend = "wg-quick"; }; inherit name; allInterfaces = allInterfaces name; }
      )
      (lib.attrsets.filterAttrs (name: interface: interface.backend == "wg-quick" && (architectureType (allInterfaces name) == "client-server")) config.modules.nixos.wireguard.interfaces));

    networking.wireguard.interfaces = (lib.mapAttrs
      (name: interface:
        wireguardDefinition { me = { host = config.networking.hostName; config = interface; backend = "wireguard"; }; inherit name; allInterfaces = allInterfaces name; }
      )
      (lib.attrsets.filterAttrs (name: interface: interface.backend == "wireguard" && (architectureType (allInterfaces name) == "client-server")) config.modules.nixos.wireguard.interfaces));

    age.secrets = (foldl' (a: b: a // b) { } (lib.mapAttrsToList
      (name: interface:
        let
          peers = allInterfaces name;
          architecture = architectureType peers;

          clients = lib.filter (peer: !peer.config.isServer) peers;
        in
        {
          "wg-${name}-key" = {
            hostSecret = "wg-${toFileName name}-key.age";
            generator.script = "wireguard-key";
          };
        } // (if interface.isServer then
          (foldl' (a: b: a // b) { } (lib.map
            (peer: {
              "wg-${name}-${peer.host}-psk" = {
                fromOtherHost.host = peer.host;
                fromOtherHost.name = "wg-${toFileName name}-psk.age";
              };
            })
            clients)) else {
          "wg-${name}-psk" = {
            hostSecret = "wg-${toFileName name}-psk.age";
            generator.script = "wireguard-psk";
          };
        }))
      (config.modules.nixos.wireguard.interfaces)));

    modules.nixos.wireguard.secrets =
      let
        content = name: {
          privateKeyFile = config.age.secrets."wg-${name}-key".path;
          presharedKeyFile = config.age.secrets."wg-${name}-psk".path;
          publicKey = readFile ../../../secrets/hosts/${config.networking.hostName}/wg-${toFileName name}-key.pub;
        };
      in
      (lib.attrsets.mapAttrs (key: val: content key) config.modules.nixos.wireguard.interfaces);

    networking.firewall.allowedUDPPorts = lib.flatten (lib.attrValues (lib.mapAttrs
      (name: interface:
        let
          peers = allPeers name;
          architecture = architectureType peers;
        in
        if interface.addFirewallAllow && interface.listenPort != null then
          [ interface.listenPort ]
        else
          [ ])
      config.modules.nixos.wireguard.interfaces));
  });
}
