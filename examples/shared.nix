{ noxa, ... }: {
  config = {
    noxa.wireguard.interfaces.wg-service = {
      networkAddress = "10.22.0.0/24";
    };

    noxa.secrets.secretsPath = ./secrets;
    noxa.secrets.options.masterIdentities = [
      {
        identity = "examples/secrets/master.key";
        pubkey = "age1l4enxs8e9ysregy76axj5alcrk86nljtsm4rje775lu0jn3r955sr4kv73";
      }
    ];
  };
}
