{ noxa, agenix, ... }: {
  config = {
    system.stateVersion = "25.11";

    noxa.wireguard.interfaces.wg-service = {
      networkAddress = "10.22.0.0/24";
    };

    noxa.secrets.secretsPath = ./secrets;
    noxa.secrets.options.masterIdentities = [
      {
        # ATTENTION: CHANGE THIS FROM A PATH TO A STRING WHEN
        # COPYING THIS TO YOUR OWN CONFIGURATION!
        # just use something like "/home/user/.noxa/master.key"
        identity = builtins.toString ./secrets/master.key;
        pubkey = "age1l4enxs8e9ysregy76axj5alcrk86nljtsm4rje775lu0jn3r955sr4kv73";
      }
    ];
    warnings = with noxa.lib.ansi; [
      # informing the user, when just copying this example
      "${bold+fgRed}=== YOU ARE USING THE ${underline}PUBLIC${noUnderline} MASTER KEY! ===${default}"
    ];
  };
}
