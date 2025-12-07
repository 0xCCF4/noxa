{ inputs, lib, self, ... }: with lib;
{
  perSystem = { pkgs, system, ... }:
    let
      hostsWithPubKey = filterAttrs (name: node: node.config.noxa.secrets.options.hostPubkey != null) self.nixosConfigurations;
      filterNonLines = str: concatStringsSep "" (split "\n" str);
      filterPubkey = str: let blocks = split " " str; in concatStringsSep " " (flatten (sublist 0 3 blocks));
      nodeToEntry = node:
        let
          pubKey = filterNonLines (filterPubkey node.config.noxa.secrets.options.hostPubkey);
          ssh = node.config.services.openssh;
          hostName = node.config.networking.hostName;
          hostNameWithPort = if (!ssh.enable || ssh.port == 22) then hostName else "[${hostName}]:${ssh.port}";
        in
        [ "${hostNameWithPort} ${pubKey}" ]
        ++ [ "${hostNameWithPort}.${node.config.networking.domain} ${pubKey}" ];
    in
    {
      packages.knownHosts = pkgs.writeText "known-hosts" (
        concatStringsSep "\n" (flatten ((mapAttrsToList (host: node: nodeToEntry node) hostsWithPubKey) ++ [ jumpServer jumpServer2 ]))
      );
    };
}
