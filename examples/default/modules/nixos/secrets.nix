{ lib, ... }: with lib; {
  config = {
    noxa.secrets.options.masterIdentities = [
      #############################
      #
      # Rekeying new file, when you have multiple
      # multiple identities owned by different users
      # AGENIX_REKEY_PRIMARY_IDENTITY=<Your public key> AGENIX_REKEY_PRIMARY_IDENTITY_ONLY=true nix run .#agenix-rekey -- rekey
      #
      #############################

      {
        identity = "/home/...";
        pubkey = "age...";
      }
    ];
    age.rekey.extraEncryptionPubkeys = [
      "age..."
    ];
    noxa.secrets.secretsPath = ../../secrets;
  };
}
