{ nixpkgs
, lib ? nixpkgs.lib
, ...
}:
with lib; with builtins;
let
  esc = fromJSON '' "\u001b" '';
  csi = params: "${esc}[" + (concatStringsSep ";" (map toString params)) + "m";
in
{
  # https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

  ansi = rec {
    inherit esc;
    inherit csi;

    fgBlack = csi [ 30 ];
    fgRed = csi [ 31 ];
    fgGreen = csi [ 32 ];
    fgYellow = csi [ 33 ];
    fgBlue = csi [ 34 ];
    fgMagenta = csi [ 35 ];
    fgCyan = csi [ 36 ];
    fgWhite = csi [ 37 ];
    fgDefault = csi [ 39 ];

    bgBlack = csi [ 40 ];
    bgRed = csi [ 41 ];
    bgGreen = csi [ 42 ];
    bgYellow = csi [ 43 ];
    bgBlue = csi [ 44 ];
    bgMagenta = csi [ 45 ];
    bgCyan = csi [ 46 ];
    bgWhite = csi [ 47 ];
    bgDefault = csi [ 49 ];

    reset = csi [ 0 ];
    bold = csi [ 1 ];
    dim = csi [ 2 ];
    italic = csi [ 3 ];
    underline = csi [ 4 ];
    blink = csi [ 5 ];
    reverse = csi [ 7 ];
    hidden = csi [ 8 ];
    strikethrough = csi [ 9 ];
    noBold = csi [ 22 ];
    noDim = csi [ 22 ];
    noItalic = csi [ 23 ];
    noUnderline = csi [ 24 ];
    noBlink = csi [ 25 ];
    noReverse = csi [ 27 ];
    noHidden = csi [ 28 ];
    noStrikethrough = csi [ 29 ];

    default = csi [ 0 39 49 ];
  };
}
