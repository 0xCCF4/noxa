{ nixpkgs
, lib ? nixpkgs.lib
, ...
}:
with lib; with builtins;
{
  secrets = rec {
    /**
      Compute a unique identifier for a secret.
      The identifier is a string that includes the prefix, module, hosts, and name.
      The hosts are sorted to ensure consistency.
    */
    computeIdentifier = { prefix ? (if length hosts <= 1 then "host" else "shared"), module, hosts ? [ ], ident }:
      let
        hostSecret = length hosts <= 1;
        sortedHosts = sortHosts hosts;
        hostString = if hostSecret then "" else concatStringsSep "," (map cleanIdentifier sortedHosts);
      in
      "${cleanIdentifier prefix}:${cleanIdentifier module}:${hostString}:${cleanIdentifier ident}";

    cleanIdentifier = strings.replaceStrings [ "/" ":" "," "." ] [ "-" "" "" "-" ];

    sortHosts = hosts: lists.naturalSort (lists.unique hosts);
  };

}
