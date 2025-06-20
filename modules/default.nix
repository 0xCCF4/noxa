noxa-inputs: {
    nixos = (import ./nixos) noxa-inputs;
    noxa = (import ./noxa) noxa-inputs;
}