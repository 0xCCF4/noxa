{ noxa, agenix, lib, config, ... }: with lib; with builtins; with noxa.lib.filesystem; {
  config = {
    noxa.secrets.secretsPath = ./.;
    noxa.secrets.options.masterIdentities = [
      {
        # ATTENTION: CHANGE THIS FROM A PATH TO A STRING WHEN
        # COPYING THIS TO YOUR OWN CONFIGURATION!
        # just use something like "/home/user/.noxa/master.key"
        #
        # example: identity = "/home/user/.noxa/master.key";
        #
        # to generate a custom master key, use:
        # mkdir -p $HOME/.noxa
        # nix shell nixpkgs#age -c age-keygen -- -o $HOME/.noxa/master.key
        #
        # then replace the following line with e.g. /home/user/.noxa/master.key
        # then replace the public key below with the generated public key (see output of age-keygen)
        identity = whenFileExistsElse ./master.key toString (a: throw "You deleted the public master key! This is good! But you need to adjust this line to point to your own master key now.");
        pubkey = "age1l4enxs8e9ysregy76axj5alcrk86nljtsm4rje775lu0jn3r955sr4kv73";
      }
    ];

    # informing the user, that they are using the public master key, that is commited
    # to the noxa repository
    #
    # you may just remove this section, if you made sure that you are not using the
    # public master key anymore
    warnings = with noxa.lib.ansi; mkIf
      (any
        (identity:
          identity.identity == whenFileExistsElse ./master.key readFile (a: trace "You deleted the public master key! This is good! But you need to adjust this line to point to your own master key now." "<>") ||
          identity.pubkey == "age1l4enxs8e9ysregy76axj5alcrk86nljtsm4rje775lu0jn3r955sr4kv73"
        )
        config.noxa.secrets.options.masterIdentities) [
      "${bold+fgRed}=== YOU ARE USING THE ${underline}PUBLIC${noUnderline} MASTER KEY! === THIS IS INSECURE!!! ===\n${fgYellow}Please check file ${fgCyan}'secrets/default.nix'${fgYellow} and change the respective settings.${default}"
    ];
  };
}
