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

  rsync -a --exclude 'result' --exclude '.git' ./ $TMPDIR/
  pushd $TMPDIR

  ${pkgs.git}/bin/git clean -fxd || true
  
  ${agenix-rekey.packages.${system}.default}/bin/agenix generate
  ${agenix-rekey.packages.${system}.default}/bin/agenix rekey

  for host in ${concatStringsSep " " (attrNames self.noxaConfiguration.config.nodes)}; do
    ${pkgs.nix}/bin/nix build .#noxaConfiguration.config.nodes.$host.build.toplevel
    rm -fd ./result/ || true
  done

  popd
'')
