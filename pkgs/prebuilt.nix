{ self
, lib
, pkgs
, mkDerivation ? pkgs.stdenv.mkDerivation
, agenix-rekey
, system
, ...
}:
with lib; with builtins;
(pkgs.writeShellScriptBin "prebuilt-examples" ''
  #!${pkgs.runtimeShell}
  set -euo pipefail

  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  cp -P -r ./* $TMPDIR/
  pushd $TMPDIR

  ${pkgs.git}/bin/git clean -fxd || true
  
  ${agenix-rekey.packages.${system}.default}/bin/agenix generate
  ${agenix-rekey.packages.${system}.default}/bin/agenix rekey

  for host in ${concatStringsSep " " (attrNames self.nixosConfigurations)}; do
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake .#$host build "$@"
    rm -Rf ./result/ || true
  done

  popd
'')
