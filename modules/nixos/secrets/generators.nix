{ lib, ... }: with lib; with builtins; {
  config =
    let
      ssh-keys = type: { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "${pkgs.busybox}/bin/rm -rf ''${TMPDIR}" EXIT
        ${pkgs.busybox}/bin/chmod 700 "''${TMPDIR}"
      
        ${pkgs.openssh}/bin/ssh-keygen -t ${type} -f "''${TMPDIR}/key" -N "" -C "" -q
        ${pkgs.busybox}/bin/cat "''${TMPDIR}/key"
        ${pkgs.busybox}/bin/cat "''${TMPDIR}/key.pub" | ${pkgs.busybox}/bin/xargs > ${escapeShellArg (removeSuffix ".age" file + ".pub")}

        ${pkgs.busybox}/bin/rm -rf "''${TMPDIR}"
      '';
    in
    {
      age.generators.wireguard-key = { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        ${pkgs.busybox}/bin/echo "$priv"
      '';

      age.generators.wireguard-psk = { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        ${pkgs.wireguard-tools}/bin/wg genpsk
      '';

      age.generators.dummy = { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        ${pkgs.busybox}/bin/echo "This is a dummy secret, not meant to be used in production."
      '';

      age.generators.nix-store-key = { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "${pkgs.busybox}/bin/rm -rf ''${TMPDIR}" EXIT
        ${pkgs.busybox}/bin/chmod 700 "''${TMPDIR}"

        PRIVATE_KEY_FILE="''${TMPDIR}/private-key.pem"
        PUBLIC_KEY_FILE="''${TMPDIR}/public-key.pem"
        ${pkgs.nix}/bin/nix-store --generate-binary-cache-key "$(basename ${file})" "''${PRIVATE_KEY_FILE}" "''${PUBLIC_KEY_FILE}"
        ${pkgs.busybox}/bin/cp "$PUBLIC_KEY_FILE" ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        ${pkgs.busybox}/bin/cat "$PRIVATE_KEY_FILE"
      
        ${pkgs.busybox}/bin/rm -rf "''${TMPDIR}"
      '';

      age.generators.tor-hidden-service = { pkgs, file, ... }: ''
        ${pkgs.busybox}/bin/mkdir -p $(${pkgs.busybox}/bin/dirname ${escapeShellArg file})
        TMPDIR=$(mktemp -d)
        trap "${pkgs.busybox}/bin/rm -rf ''${TMPDIR}" EXIT
        ${pkgs.busybox}/bin/chmod 700 "''${TMPDIR}"

        ${pkgs.busybox}/bin/mkdir -p "''${TMPDIR}/onion-service/"
        ${pkgs.busybox}/bin/chmod 700 "''${TMPDIR}/onion-service/"
        ${pkgs.busybox}/bin/mkdir -p "''${TMPDIR}/tor-data/"
        ${pkgs.busybox}/bin/chmod 700 "''${TMPDIR}/tor-data/"

        ${pkgs.util-linux}/bin/unshare --net --map-current-user ${pkgs.busybox}/bin/timeout 5s ${pkgs.tor}/bin/tor --RunAsDaemon 0 --DataDirectory ''${TMPDIR}/tor-data --HiddenServiceDir ''${TMPDIR}/onion-service --HiddenServicePort 9999 > /dev/null

        ${pkgs.busybox}/bin/cat "''${TMPDIR}/onion-service/hs_ed25519_secret_key"
        ${pkgs.busybox}/bin/cp "''${TMPDIR}/onion-service/hs_ed25519_public_key" ${escapeShellArg (removeSuffix ".age" file + ".pub")}
        ${pkgs.busybox}/bin/cp "''${TMPDIR}/onion-service/hostname" ${escapeShellArg (removeSuffix ".age" file + ".name")}

        ${pkgs.busybox}/bin/rm -rf "''${TMPDIR}"
      '';

      age.generators.ssh-keys-ed25519 = ssh-keys "ed25519";
      age.generators.ssh-keys-rsa = ssh-keys "rsa";
    };
}
