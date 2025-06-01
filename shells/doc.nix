{ pkgs, ... }:
pkgs.mkShell {
  name = "noxa-doc";
  buildInputs = with pkgs; [
    mdbook
    mdbook-linkcheck
    mdbook-admonish
    mdbook-mermaid
  ];
  shellHook = ''
    export MDBOOK_THEME=rust
  '';
}
