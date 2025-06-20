noxa-inputs: {
    nixos = (imports ./nixos) noxa-inputs;
    noxa = (imports ./noxa) noxa-inputs;
}