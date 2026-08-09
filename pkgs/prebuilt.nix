{ lib
, pkgs
, mkDerivation ? pkgs.stdenv.mkDerivation
, agenix-rekey
, system
, ...
}:
with lib; with builtins;
# Builds every `nixosConfigurations` entry of the flake in the current directory.
# Run this from inside `examples/minimal` or `examples/default` to smoke-test that example.
(pkgs.writeShellScriptBin "prebuilt-examples" ''
  #!${pkgs.runtimeShell}
  set -euo pipefail

  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  rsync -a --exclude 'result' --exclude '.git' ./ $TMPDIR/
  pushd $TMPDIR

  ${pkgs.git}/bin/git clean -fxd || true

  ${agenix-rekey.packages.${system}.default}/bin/agenix generate
  ${agenix-rekey.packages.${system}.default}/bin/agenix rekey

  hosts=$(${pkgs.nix}/bin/nix eval --json .#nixosConfigurations --apply builtins.attrNames)
  for host in $(${pkgs.jq}/bin/jq -r '.[]' <<< "$hosts"); do
    ${pkgs.nix}/bin/nix build .#nixosConfigurations."$host".config.system.build.toplevel
    rm -fd ./result/ || true
  done

  popd
'')
