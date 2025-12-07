{ config, lib, users, pkgs, self, ... }@inputs: with lib; with builtins;
{
  options.mine = with types; {
    users = mkOption {
      type = listOf str;
      default = [ ];
      description = "List of users to be created on the system.";
    };
    admins = mkOption {
      type = listOf str;
      default = [ ];
      description = "List of users to be given admin (wheel) privileges.";
    };
    allowDialout = mkOption {
      type = types.bool;
      default = config.mine.isWorkstation;
      description = ''
        All users are added to the "dialout" group to allow serial port access.
      '';
    };
    addPublicKeysForNonAdmins = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add the public keys of non-admin users to the system for SSH access.";
    };
  };

  config =
    let
      uniqUsers = unique config.mine.users;
      usersNotInConfig = filter (user: !(hasAttr user users)) uniqUsers;
    in
    {
      assertions = [
        {
          assertion = length usersNotInConfig == 0;
          message = "The user '${head usersNotInConfig}' is listed as a user on the system but is not defined in the 'users' module.";
        }
      ];

      # all admins are also users
      mine.users = config.mine.admins;

      users.users = mkMerge (map
        (userName:
          let
            userModule = users.${userName};
          in
          {
            "${userName}" = {
              isNormalUser = true;
              uid = userModule.uid;
              extraGroups = (optional (elem userName config.mine.admins) "wheel") ++ (optional config.mine.allowDialout "dialout");
              hashedPassword = mkIf (userModule ? "hashedPassword") userModule.hashedPassword;
              openssh.authorizedKeys.keys = mkIf (elem userName config.mine.admins || config.mine.addPublicKeysForNonAdmins) userModule.authorizedKeys;
              shell = mkIf (userModule ? "shell") (mkOverride 800 (
                if userModule.shell == "bash" then pkgs.bash
                else if userModule.shell == "zsh" then pkgs.zsh
                else if userModule.shell == "fish" then pkgs.fish
                else pkgs.bash
              ));
            };
          }
        )
        uniqUsers);

      programs.fish.enable = mkDefault (any (user: hasAttr "shell" users.${user} && users.${user}.shell == "fish") uniqUsers);
      programs.zsh.enable = mkDefault (any (user: hasAttr "shell" users.${user} && users.${user}.shell == "zsh") uniqUsers);
      programs.bash.enable = mkDefault true;

      nix.settings.trusted-public-keys = mkMerge (map (user: mkIf (hasAttr "trustedNixKeys" users.${user}) users.${user}.trustedNixKeys) config.mine.admins);

      home-manager = {
        backupFileExtension = "hmbackup";
        useUserPackages = true;
        useGlobalPkgs = true;

        extraSpecialArgs = {
          inherit inputs;
          inherit self;
          inherit pkgs;

          inherit (inputs) noxa;
          inherit (inputs) stylix;
          inherit (inputs) home-manager;
          inherit (inputs) impermanence;
          inherit (inputs) vscode-server;

          osConfig = foldl recursiveUpdate { } ([ config ] ++ (map (username: (users."${username}".homeConfigOverwrite or ({ ... }: { }) inputs)) uniqUsers));
        };

        users = mkMerge (map
          (userName:
            let
              userModule = if userName != "root" then users.${userName} else { };
            in
            {
              "${userName}" =
                { ... }: {
                  imports = [
                    self.hmModules.default
                    (userModule.home or { })
                  ];

                  config = {
                    home.username = mkDefault userName;
                    home.stateVersion = mkDefault config.system.stateVersion;

                    programs.ssh.enable = mkIf (userName == "root") (mkDefault true);
                    programs.ssh.enableDefaultConfig = mkDefault false;
                    programs.ssh.matchBlocks."*" = {
                      forwardAgent = mkDefault false;
                      serverAliveInterval = mkDefault 0;
                      serverAliveCountMax = mkDefault 3;
                      compression = mkDefault false;
                      hashKnownHosts = mkDefault false;
                      controlMaster = mkDefault "no";
                      controlPath = mkDefault "~/.ssh/master-%r@%n:%p";
                      controlPersist = mkDefault "no";
                    };
                  };
                };
            }
          )
          (uniqUsers ++ [ "root" ]));
      };
    };
}
