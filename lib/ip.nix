{ nixpkgs
, lib ? nixpkgs.lib
, ...
}:
with builtins; with lib;
let
  rep2Add = mask: val:
    if mask == 0 then
      0
    else
      2 * (rep2Add (mask - 1) val) + val;

  checkInt = val: match "[0-9]+" val != null;
  checkHex = val: match "^[0-9a-fA-F]+$" val != null;
in rec {

  /**
    Computes the power of a number raised to a positive integer exponent.
    If the exponent is negative, an error is thrown.

    # Inputs
    `val` : The base number (should be a number).
    `exp` : The exponent (should be an positive integer).

    # Output
    The result of `val` raised to the power of `exp`.

    # Type
    ```nix
    Int -> Int -> Number
    ```
  */
  pow = val: exp:
    if typeOf val != "int" || typeOf exp != "int" then
      throw "pow expects integers, got ${toString val}^${toString exp}"
    else if exp < 0 then
      throw "pow does not support negative exponents, got ${toString exp}"
    else if exp == 0 then
      1
    else if exp == 1 then
      val
    else
      val * pow val (exp - 1);


  ipN = meta: rec {
    /**
      Network part of an IP address represented as integer by cutting of the device part

      # Input
      `addressParts` : A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4] for 1.2.3.4
      `mask` : An integer representing the CIDR mask.

      # Output
      An integer representing the normalized IP address.

      # Example
      The IPv4 address 1.1.1.8/24 will be normalized to 1.1.1.0/24.

      # Type
      ```nix
      [ Int ] -> Int -> Int
      ```
        */
    networkPart = addressParts: mask:
      if !checkIpInt addressInt || !checkIpMask mask then
        throw "Illegal arguments"
      else
        bitAnd addressInt (calculateNetworkMaskInt mask);

    /**
      Converts an IP address represented as list of integers to its string representation in CIDR notation.

      # Input
      `addressParts` : A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4]
      `mask` : An integer representing the CIDR mask.

      # Output
      A string representing the IP address in CIDR notation

      # Type
      ```nix
      Int -> Int -> String
      ```
      */
    composeStr = addressParts: mask: "${concatStringsSep meta.componentSeparator (map meta.componentToString addressParts)}/${toString mask}";

    /**
      Computes the network mask list for an IP address given a CIDR mask.

      # Input
      `mask` : An integer representing the CIDR mask.

      # Output
      A list of integers representing the network mask for the given CIDR mask.

      # Type
      ```nix
      Int -> [ Int ]
      ```
      */
        calculateNetworkMaskParts = mask:
      if !checkIpMask mask then
        throw "Illegal arguments"
      else
        genList (i:
          let
        startOfComponent = i * meta.componentBitWidth;
        endOfComponent = startOfComponent + meta.componentBitWidth;
        bitsInComponent = max (min (mask - startOfComponent) meta.componentBitWidth) 0;
        in
        if mask <= startOfComponent then 0
          else if mask >= endOfComponent then meta.componentMask
          else (rep2Add bitsInComponent 1) * pow 2 (meta.componentBitWidth - bitsInComponent)
        ) meta.components;

    /**
      Computes the device mask for an IP address given a CIDR mask.

      # Input
      `mask` : An integer representing the CIDR mask.

      # Output
      An list of integers representing the device mask for the given CIDR mask.

      # Type
      ```nix
      Int -> [ Int ]
      ```
      */
    calculateDeviceMaskParts = mask:
      map (part: bitAnd (bitNot part) meta.componentMask) (calculateNetworkMaskParts mask);

    /**
      Decomposes an IP address in CIDR notation into its components.
      Same as `decompose`, but returns `null` if the input is invalid.

      # Input
      `val` : A string representing the IP address in CIDR notation, e.g. "1.2.3.4/32".

      # Output
      An attribute set containing the following fields:
      - `addressParts`: A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4].
      - `address`: The normalized IP address in CIDR notation as a string.
      - `networkParts`: A list of integers representing the network part of the IP address.
      - `network`: The network part of the IP address as string.
      - `deviceParts`: A list of integers representing the device part of the IP address.
      - `device`: The device part of the IP address as string.
      - `mask`: The CIDR mask as an integer.

      If the input is invalid, it will return `null`

      # Type
      ```nix
      String -> { addressParts : [ Int ], address : String, networkParts : [ Int ], network : String, deviceParts : [ Int ], device : String, mask : Int } | null
      ```
        */
    decompose' = val:
      let
        validString = typeOf val == "string";

        parts = splitString "/" val;
        address = head parts;
        mask = if length parts > 1 then last parts else meta.bitWidth;
        validMask = length parts <= 2 && checkInt mask && toInt mask >= 0 && toInt mask <= meta.bitWidth;

        chunkedAddress = meta.strToParts address;
        validAddressPart = all (part: let
          partInt = meta.componentFromString part;
          in
          meta.componentIsValidString part && partInt >= 0 && partInt <= meta.componentMask) chunkedAddress;

        chunks = map toInt chunkedAddress;
        maskInt = toInt mask;
        networkMask = calculateNetworkMaskParts maskInt;
        deviceMask = calculateDeviceMaskParts maskInt;

        networkPartInt = bitAnd addressInt networkMask;
        devicePartInt = bitAnd addressInt deviceMask;

        compose = adr: composeStr adr maskInt;
      in
      if (validString && validMask && validAddressPart) then {
        addressParts = chunks;
        address = compose chunks;
        networkParts = networkMask;
        network = compose networkMask;
        deviceParts = deviceMask;
        device = compose deviceMask;
        mask = maskInt;
      } else null;

    /**
      Decomposes an IP address in CIDR notation into its components.
      Same as `decompose'`, but throws an error if the input is invalid.

      # Input
      `val` : A string representing the IP address in CIDR notation, e.g. "1.2.3.4/32".

      # Output
      An attribute set containing the following fields:
      - `addressInt`: The normalized IP address as an integer.
      - `givenAddressInt`: The original IP address as an integer (no normalization applied).
      - `mask`: The CIDR mask as an integer.
      - `normalizedStr`: The normalized IP address in CIDR notation as a string.
      If the input is invalid, it will return `null`

      # Type
      ```nix
      String -> { addressInt : Int, givenAddressInt : Int, mask : Int, normalizedStr : String }
      ```
      */
    decompose = val:
      let result = decompose' val; in
      if result != null then result else throw "Invalid ${meta.description}: ${toString val}";

    /**
      Checks if the given value is a valid IP address represented as an list of integers.

      # Input
      `val` : A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4]

      # Output
      A boolean indicating whether the input is a valid IP address represented as an list of integers.

      # Type
      ```nix
      [ Int ] -> Bool
      ```
      */
    checkIpParts = val: typeOf val == "list" && all (part: typeOf part == "int" && part >= 0 && part <= meta.componentMask);

    /**
      Checks if the given value is a valid IP mask.

      # Input
      `val` : An integer representing the CIDR mask.

      # Output
      A boolean indicating whether the input is a valid IP mask.
      
      # Type
      ```nix
      Int -> Bool
      ```
      */
    checkIpMask = mask: typeOf mask == "int" && mask >= 0 && mask <= meta.bitWidth;

    /**
      Checks if the given value is a valid IP address in CIDR notation. The IP
      address must be normalized, i.e. no device part is present.

      # Input
      `val` : A string representing the IP address in CIDR notation

      # Output
      A boolean indicating whether the input is a valid IP address in CIDR notation
      without device part.

      # Type
      ```nix
      String -> Bool
      ```
      */
    checkNormalizedNetwork =
      let
        result = decompose' val;
      in
      val: result != null && result.addressInt == result.networkPartInt;

    /**
      Checks if the given value is a valid IP address in CIDR notation.

      # Input
      `val` : A string representing the IP address in CIDR notation, e.g. "1.2.3.4/32".

      # Output
      A boolean indicating whether the input is a valid IP address in CIDR notation.

      # Type
      ```nix
      String -> Bool
      ```
      */
    check = val: decompose' val != null;

    inherit meta;
  };

  ip4 = ipN {
    components = 4; # In string representation
    componentMask = 255; # used for bitwise operations
    componentBitWidth = 8; # In bits
    componentSeparator = ".";
    description = "IPv4 address";
    bitWidth = 32;
    componentIsValidString = checkInt;
    componentFromString = toInt;
    componentToString = toString;
    strToParts = splitString ".";
  };

  ip6 = ipN {
    components = 8; # In string representation
    componentMask = 65535; # used for bitwise operations
    componentBitWidth = 16; # In bits
    componentSeparator = ":"; # In string representation
    description = "IPv6 address";
    bitWidth = 128;
    componentIsValidString = checkHex;
    componentFromString = trivial.fromHexString;
    componentToString = trivial.toHexString;
    strToParts = splitString ":";
  };

  types.ip = lib.types.oneOf [ types.ip4 types.ip6 ];

  types.ip4 = lib.mkOptionType {
    name = "ip4";
    description = "IPv4 address";
    descriptionClass = "noun";
    check = ip4.check;
  };

  types.ip6 = lib.mkOptionType {
    name = "ip6";
    description = "IPv6 address";
    descriptionClass = "noun";
    check = ip6.check;
  };

  test = {
    #maskNet = ip4.composeStr (ip4.calculateNetworkMaskParts 24) 24;
    #maskDevice = ip4.composeStr (ip4.calculateDeviceMaskParts 24) 24;
    #maskNetInt = ip4.calculateNetworkMaskParts 24;
    #maskDeviceInt = ip4.calculateDeviceMaskParts 24;
    #ip4 = ip4.decompose' "1.1.1.55/24";
    ip6 = ip6.decompose "1:2:3:4:5:6:7:8/64";
    };
}
