{ ... }:
{
    imports = [
        ../hardware/vm.nix
    ];

    networking.hostName = "hostA";

    system.stateVersion = "25.11";
}
