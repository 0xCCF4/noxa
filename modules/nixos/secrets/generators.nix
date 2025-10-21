{ lib, ... }: with lib; with builtins; {
  config =
    let
      ssh-keys = type: { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "rm -rf ''${TMPDIR}" EXIT
        chmod 700 "''${TMPDIR}"
      
        ssh-keygen -t ${type} -f key -N "" -C "" -q
        cat key
        cp key.pub ${escapeShellArg (removeSuffix ".age" file + ".pub")}

        rm -rf "''${TMPDIR}"
      '';
    in
    {
      age.generators.wireguard-key = { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';

      age.generators.wireguard-psk = { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        ${pkgs.wireguard-tools}/bin/wg genpsk
      '';

      age.generators.dummy = { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        echo "This is a dummy secret, not meant to be used in production."
      '';

      age.generators.nix-store-key = { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "rm -rf ''${TMPDIR}" EXIT
        chmod 700 "''${TMPDIR}"

        PRIVATE_KEY_FILE="''${TMPDIR}/private-key.pem"
        PUBLIC_KEY_FILE="''${TMPDIR}/public-key.pem"
        ${pkgs.nix}/bin/nix-store --generate-binary-cache-key "$(basename ${file})" "''${PRIVATE_KEY_FILE}" "''${PUBLIC_KEY_FILE}"
        cp "$PUBLIC_KEY_FILE" ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        cat "$PRIVATE_KEY_FILE"
      
        rm -rf "''${TMPDIR}"
      '';

      age.generators.tor-hidden-service = { pkgs, file, ... }: ''
        mkdir -p $(dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "rm -rf ''${TMPDIR}" EXIT
        chmod 700 "''${TMPDIR}"

        mkdir -p "''${TMPDIR}/onion-service/"
        chmod 700 "''${TMPDIR}/onion-service/"
        mkdir -p "''${TMPDIR}/tor-data/"
        chmod 700 "''${TMPDIR}/tor-data/"

        unshare --net --map-current-user timeout 5s ${pkgs.tor}/bin/tor --RunAsDaemon 0 --DataDirectory ''${TMPDIR}/tor-data --HiddenServiceDir ''${TMPDIR}/onion-service --HiddenServicePort 9999 > /dev/null

        cat "''${TMPDIR}/onion-service/hs_ed25519_secret_key"
        cp "''${TMPDIR}/onion-service/hs_ed25519_public_key" ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        cp "''${TMPDIR}/onion-service/hostname" ${escapeShellArg (removeSuffix ".age" file + ".name")}

        rm -rf "''${TMPDIR}"
      '';

      age.generators.ssh-keys-ed25519 = ssh-keys "ed25519";
      age.generators.ssh-keys-rsa = ssh-keys "rsa";
    };
}
