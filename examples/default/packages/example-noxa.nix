{ lib
, writeShellApplication
}: with lib; writeShellApplication {
  name = "example-noxa";
  text = ''
    echo "Example derivation"
  '';
}
