{lib, ...}: with lib; with builtins; {
    config = {
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
      TRAP 'rm -rf "$TMPDIR"' EXIT
      PRIVATE_KEY_FILE="${TMPDIR}/private-key.pem"
      PUBLIC_KEY_FILE="${TMPDIR}/public-key.pem"
      ${pkgs.nix}/bin/nix-store --generate-binary-cache-key "$(basename ${file})" "$PRIVATE_KEY_FILE" "$PUBLIC_KEY_FILE"
      cp "$PUBLIC_KEY_FILE" ${escapeShellArg (removeSuffix ".age" file + ".pub")}
      cat "$PRIVATE_KEY_FILE"
      rm -rf "$TMPDIR"
    '';
    };
}