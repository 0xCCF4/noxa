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

  checkInt = val:
    if typeOf val == "int" then
      true
    else if typeOf val == "string" then
      match "[0-9]+" val != null
    else
      false;
  checkHex = val: match "^[0-9a-fA-F]+$" val != null;

  ipGapSplit = meta: str:
    let
      parts = splitString meta.componentSeparator str;
      indexedParts = lists.zipLists parts (genList (i: i) (length parts));
      gaps = filter (part: part.fst == "") indexedParts;

      gapIndex = (head gaps).snd;

      lstBeforeGap = lists.sublist 0 gapIndex parts;
      lstAfterGap = lists.sublist (gapIndex + 1) (length parts) parts;
      lstFiller = genList (i: "0") (meta.components - length parts + 1);
    in
      if length gaps > 1 then
        null
      else if length gaps == 0 then
        parts
      else
        lstBeforeGap ++ lstFiller ++ lstAfterGap;

  ipGapJoin = meta: parts:
    let
      findGaps = foldl (acc: part: let
        currentGapOrNull = filter (x: x.end == part.index - 1) acc;
        currentGap = if length currentGapOrNull > 0 then head currentGapOrNull // {end=part.index;} else {start=part.index; end=part.index;};
      in
        if part.value == 0 then
          (filter (gap: gap.start != currentGap.start) acc) ++ [currentGap]
        else
          acc
      ) [] (map (x: {value = x.fst; index = x.snd;}) (lists.zipLists parts (genList (i: i) meta.components)));

      longestGap = if length findGaps == 0 then
        null
      else
        foldl (acc: gap: if gap.end - gap.start > acc.end - acc.start then gap else acc) (head findGaps) findGaps;

      strParts = map meta.componentToString parts;

      lstBeforeGap = if longestGap.start == 0 then
        [""]
      else
        lists.sublist 0 longestGap.start strParts;

      lstAfterGap = if longestGap.end == meta.components - 1 then
        [""]
      else
        lists.sublist (longestGap.end + 1) meta.components strParts;

      strPartsRemovedGap = if longestGap == null then
        strParts
      else
        lstBeforeGap ++ [""] ++ lstAfterGap;
    in
    concatStringsSep ":" strPartsRemovedGap;
in
rec {

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
      Converts an IP address represented as list of integers to its string representation in CIDR notation.

      # Input
      `addressParts` : A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4]
      `mask` : An integer representing the CIDR mask.

      # Output
      A string representing the IP address in CIDR notation

      # Type
      ```nix
      [ Int ] -> Int | null -> String
      ```
      */
    composeStr = addressParts: mask:
      if mask != null then
        "${meta.partsToStr addressParts}/${toString mask}"
      else
        "${meta.partsToStr addressParts}";

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
        genList
          (i:
            let
              startOfComponent = i * meta.componentBitWidth;
              endOfComponent = startOfComponent + meta.componentBitWidth;
              bitsInComponent = max (min (mask - startOfComponent) meta.componentBitWidth) 0;
            in
            if mask <= startOfComponent then 0
            else if mask >= endOfComponent then meta.componentMask
            else (rep2Add bitsInComponent 1) * pow 2 (meta.componentBitWidth - bitsInComponent)
          )
          meta.components;

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
      Computes the bitwise AND of two lists of integers representing IP address parts.

      # Input
      `addressParts` : A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4]
      `maskParts` : A list of integers representing the mask for the IP address.

      # Output
      A list of integers representing the result of the bitwise AND operation on each corresponding component.

      # Type
      ```nix
      [ Int ] -> [ Int ] -> [ Int ]
      ```
      */
    partsBitAnd = addressParts: maskParts:
      if length addressParts != length maskParts then
        throw "partsBitAnd expects lists of equal length, got ${toString (length addressParts)} and ${toString (length maskParts)}"
      else
        map (x: bitAnd x.fst x.snd) (lists.zipLists addressParts maskParts);

    /**
      Decomposes an IP address in CIDR notation into its components.
      Same as `decompose`, but returns `null` if the input is invalid.

      # Input
      `val` : A string representing the IP address in CIDR notation, e.g. "1.2.3.4/32".

      # Output
      An attribute set containing the following fields:
      - `addressParts`: A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4].
      - `address`: The normalized IP address in CIDR notation as a string.
      - `addressNoMask`: The normalized IP address without trailing /mask as a string.
      - `networkParts`: A list of integers representing the network part of the IP address.
      - `network`: The network part of the IP address as string.
      - `networkNoMask`: The network part of the IP address without trailing /mask as a string.
      - `deviceParts`: A list of integers representing the device part of the IP address.
      - `device`: The device part of the IP address as string.
      - `deviceNoMask`: The device part of the IP address without trailing /mask as a string.
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
        mask = if length parts > 1 then last parts else toString meta.bitWidth;
        validMask = length parts <= 2 && checkInt mask && toInt mask >= 0 && toInt mask <= meta.bitWidth;

        chunkedAddress = meta.strToParts address;
        validAddressPart = chunkedAddress != null && all
          (part:
            let
              partInt = meta.componentFromString part;
            in
            meta.componentIsValidString part && partInt >= 0 && partInt <= meta.componentMask)
          chunkedAddress;

        chunks = map toInt chunkedAddress;
        maskInt = toInt mask;
        networkMask = calculateNetworkMaskParts maskInt;
        deviceMask = calculateDeviceMaskParts maskInt;

        networkPart = partsBitAnd chunks networkMask;
        devicePart = partsBitAnd chunks deviceMask;

        compose = adr: composeStr adr maskInt;
        composeNoMask = adr: composeStr adr null;
      in
      if (validString && validMask && validAddressPart) then {
        addressParts = chunks;
        address = compose chunks;
        addressNoMask = composeNoMask chunks;
        networkParts = networkPart;
        network = compose networkPart;
        networkNoMask = composeNoMask networkPart;
        deviceParts = devicePart;
        device = compose devicePart;
        deviceNoMask = composeNoMask devicePart;
        mask = maskInt;
      } else null;

    /**
      Decomposes an IP address in CIDR notation into its components.
      Same as `decompose'`, but throws an error if the input is invalid.

      # Input
      `val` : A string representing the IP address in CIDR notation, e.g. "1.2.3.4/32".

      # Output
      An attribute set containing the following fields:
      - `addressParts`: A list of integers representing the IP address in its components, e.g. [1, 2, 3, 4].
      - `address`: The normalized IP address in CIDR notation as a string.
      - `addressNoMask`: The normalized IP address without trailing /mask as a string.
      - `networkParts`: A list of integers representing the network part of the IP address.
      - `network`: The network part of the IP address as string.
      - `networkNoMask`: The network part of the IP address without trailing /mask as a string.
      - `deviceParts`: A list of integers representing the device part of the IP address.
      - `device`: The device part of the IP address as string.
      - `deviceNoMask`: The device part of the IP address without trailing /mask as a string.
      - `mask`: The CIDR mask as an integer.
      If the input is invalid, it will throw an error.

      # Type
      ```nix
      String -> { addressParts : [ Int ], address : String, networkParts : [ Int ], network : String, deviceParts : [ Int ], device : String, mask : Int }
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
    checkIpParts = val: typeOf val == "list" && all (part: typeOf part == "int" && part >= 0 && part <= meta.componentMask) val && length val == meta.components;

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

    /** Checks if the given value is a valid IP address in CIDR notation without trailing /mask.

      # Input
      `val` : A string representing the IP address, e.g. "1.2.3.4".

      # Output
      A boolean indicating whether the input is a valid IP address without trailing /mask.

      # Type
      ```nix
      String -> Bool
      ```
      */
    checkNoMask = val:
      let
        result = decompose' val;
      in
      result != null && result.addressNoMask == val;

    types.ip = lib.mkOptionType {
      name = meta.name;
      description = meta.description;
      descriptionClass = "noun";
      check = check;
    };

    types.ipNoMask = lib.mkOptionType {
      name = "${meta.name}NoMask";
      description = "${meta.description} without trailing /mask";
      descriptionClass = "noun";
      check = checkNoMask;
    };

        types.ipNetwork = lib.mkOptionType {
      name = "${meta.name}Network";
      description = "Normalized network part of an ${meta.description}";
      descriptionClass = "noun";
      check = checkNormalizedNetwork;
    };

    inherit meta;
  };

  ip4 = ipN rec {
    components = 4; # In string representation, how many parts an IPv4 address has
    componentMask = 255; # Maximum value for each component
    componentBitWidth = 8; # Bit width of each component
    componentSeparator = "."; # In string representation, how components are separated
    description = "IPv4 address"; # Description of the IP type
    name = "ip4"; # Name of the IP type
    bitWidth = 32; # Total bit width of an IPv4 address
    componentIsValidString = checkInt; # Function to check if a string is a valid component
    componentFromString = toInt; # Function to convert a component string to an integer
    componentToString = toString; # Function to convert a component integer to a string
    strToParts = splitString "."; # Function to split a string representation of an IP address into its components
    partsToStr = addressParts: concatStringsSep componentSeparator (map componentToString addressParts); # Function to convert a list of components to a string representation
  };

  ip6 = ipN rec {
    components = 8; # In string representation, how many parts an IPv6 address has
    componentMask = 65535; # Maximum value for each component
    componentBitWidth = 16; # Bit width of each component
    componentSeparator = ":"; # In string representation, how components are separated
    description = "IPv6 address"; # Description of the IP type
    name = "ip6"; # Name of the IP type
    bitWidth = 128; # Total bit width of an IPv6 address
    componentIsValidString = checkHex; # Function to check if a string is a valid component
    componentFromString = trivial.fromHexString; # Function to convert a component string to an integer
    componentToString = trivial.toHexString; # Function to convert a component integer to a string
    strToParts = ipGapSplit ip6.meta; # Function to split a string representation of an IP address into its components
    partsToStr = ipGapJoin ip6.meta; # Function to convert a list of components to a string representation
  };

  types = {
    ip = lib.types.oneOf [ ip4.types.ip ip6.types.ip ];
    ip4 = ip4.types.ip;
    ip6 = ip6.types.ip;
    ipNetwork = lib.types.oneOf [ ip4.types.ipNetwork ip6.types.ipNetwork ];
    ip4Network = ip4.types.ipNetwork;
    ip6Network = ip6.types.ipNetwork;
  };

  tests =
    let
      testCases = [
        {
          expression = pow 2 10;
          expected = 1024;
          description = "2^10 should be 1024";
        }

        {
          expression = ip4.composeStr [ 1 2 3 4 ] 24;
          expected = "1.2.3.4/24";
          description = "IP parts to string conversion";
        }
        {
          expression = ip4.calculateNetworkMaskParts 24;
          expected = [ 255 255 255 0 ];
          description = "IPv4 network mask for /24";
        }
        {
          expression = ip4.calculateNetworkMaskParts 13;
          expected = [ 255 248 0 0 ];
          description = "IPv4 device mask for /13";
        }
        {
          expression = ip4.calculateDeviceMaskParts 24;
          expected = [ 0 0 0 255 ];
          description = "IPv4 device mask for /24";
        }
        {
          expression = ip4.calculateDeviceMaskParts 13;
          expected = [ 0 7 255 255 ];
          description = "IPv4 device mask for /13";
        }
        {
          expression = ip4.decompose' "178.22.33.1/24";
          expected = {
            addressParts = [ 178 22 33 1 ];
            address = "178.22.33.1/24";
            addressNoMask = "178.22.33.1";
            networkParts = [ 178 22 33 0 ];
            network = "178.22.33.0/24";
            networkNoMask = "178.22.33.0";
            deviceParts = [ 0 0 0 1 ];
            device = "0.0.0.1/24";
            deviceNoMask = "0.0.0.1";
            mask = 24;
          };
          description = "Decomposing a valid IPv4 address";
        }
        {
          expression = ip4.decompose' "33--d";
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip4.decompose' 22;
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip4.decompose' {};
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip4.decompose' "178.22.33.1/13";
          expected = {
            addressParts = [ 178 22 33 1 ];
            address = "178.22.33.1/13";
            addressNoMask = "178.22.33.1";
            networkParts = [ 178 16 0 0 ];
            network = "178.16.0.0/13";
            networkNoMask = "178.16.0.0";
            deviceParts = [ 0 6 33 1 ];
            device = "0.6.33.1/13";
            deviceNoMask = "0.6.33.1";
            mask = 13;
          };
          description = "Decomposing a valid IPv4 address with /13 mask";
        }
        {
          expression = ip4.checkIpParts [ 178 22 33 1 ];
          expected = true;
          description = "Checking valid IPv4 parts";
        }
        {
          expression = ip4.checkIpParts [ 700 22 33 1 ];
          expected = false;
          description = "Checking invalid IPv4 parts";
        }
        {
          expression = ip4.checkIpParts [ 178 22 33 ];
          expected = false;
          description = "Checking incomplete IPv4 parts";
        }
        {
          expression = ip4.checkIpParts [ 178 22 33 2 3 ];
          expected = false;
          description = "Checking invalid IPv4 parts";
        }
        {
          expression = ip4.checkIpMask 24;
          expected = true;
          description = "Checking valid IPv4 mask";
        }
        {
          expression = ip4.checkIpMask 32;
          expected = true;
          description = "Checking valid IPv4 mask";
        }
        {
          expression = ip4.checkIpMask 33;
          expected = false;
          description = "Checking invalid IPv4 mask";
        }
        {
          expression = ip4.checkIpMask (-1);
          expected = false;
          description = "Checking negative IPv4 mask";
        }

        {
          expression = ip6.composeStr [ 1 2 3 4 5 6 7 8 ] 24;
          expected = "1:2:3:4:5:6:7:8/24";
          description = "IP parts to string conversion";
        }
        {
          expression = ip6.composeStr [ 1 0 0 4 0 0 0 8 ] 24;
          expected = "1:0:0:4::8/24";
          description = "IP parts to string conversion";
        }
        {
          expression = ip6.composeStr [ 0 0 0 4 0 0 0 8 ] 24;
          expected = "::4:0:0:0:8/24";
          description = "IP parts to string conversion";
        }
        {
          expression = ip6.composeStr [ 1 0 0 0 0 0 0 0 ] 24;
          expected = "1::/24";
          description = "IP parts to string conversion";
        }
        {
          expression = ip6.calculateNetworkMaskParts 24;
          expected = [ 65535 65280 0 0 0 0 0 0 ];
          description = "IPv4 network mask for /24";
        }
        {
          expression = ip6.calculateNetworkMaskParts 13;
          expected = [ 65528 0 0 0 0 0 0 0 ];
          description = "IPv4 device mask for /13";
        }
        {
          expression = ip6.calculateDeviceMaskParts 24;
          expected = [ 0 255 65535 65535 65535 65535 65535 65535 ];
          description = "IPv4 device mask for /24";
        }
        {
          expression = ip6.calculateDeviceMaskParts 13;
          expected = [ 7 65535 65535 65535 65535 65535 65535 65535 ];
          description = "IPv4 device mask for /13";
        }
        {
          expression = ip6.decompose' "1:2:3:4::1/64";
          expected = {
            addressParts = [ 1 2 3 4 0 0 0 1 ];
            address = "1:2:3:4::1/64";
            addressNoMask = "1:2:3:4::1";
            networkParts = [ 1 2 3 4 0 0 0 0 ];
            network = "1:2:3:4::/64";
            networkNoMask = "1:2:3:4::";
            deviceParts = [ 0 0 0 0 0 0 0 1 ];
            device = "::1/64";
            deviceNoMask = "::1";
            mask = 64;
          };
          description = "Decomposing a valid IPv4 address";
        }
        {
          expression = ip6.decompose' "33--d";
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip6.decompose' "1::2::4/64";
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip6.decompose' 22;
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip6.decompose' {};
          expected = null;
          description = "Invalid IP address should return null";
        }
        {
          expression = ip6.checkIpParts [ 1 2 3 4 5 6 7 8 ];
          expected = true;
          description = "Checking valid IPv6 parts";
        }
        {
          expression = ip6.checkIpParts [ 70000 2 3 4 5 6 7 8 ];
          expected = false;
          description = "Checking invalid IPv6 parts";
        }
        {
          expression = ip6.checkIpParts [ 1 2 3 4 5 6 7 ];
          expected = false;
          description = "Checking incomplete IPv6 parts";
        }
        {
          expression = ip6.checkIpParts [ 1 2 3 4 5 6 7 8 9 ];
          expected = false;
          description = "Checking invalid IPv6 parts";
        }
        {
          expression = ip6.checkIpMask 64;
          expected = true;
          description = "Checking valid IPv6 mask";
        }
        {
          expression = ip6.checkIpMask 128;
          expected = true;
          description = "Checking valid IPv6 mask";
        }
        {
          expression = ip6.checkIpMask 129;
          expected = false;
          description = "Checking invalid IPv6 mask";
        }
        {
          expression = ip6.checkIpMask (-1);
          expected = false;
          description = "Checking negative IPv6 mask";
        }
      ];
    in
    foldl
      (acc: testCase: let
        expression = testCase.expression;
        expected = testCase.expected;
        description = testCase.description;

        allEqual = list: all (x: x == head list) list;

        zipped = attrsets.zipAttrs [expression expected];
        onlyDifference = attrsets.filterAttrs (k: v: !(allEqual v) || length v != 2) zipped;

        differenceSet = attrNames onlyDifference;

        mismatchString = if typeOf expected == "string" then
          "Expected ${toJSON expected}, got ${toJSON expression}."
          else if typeOf expected == "set" then
            "Difference in attributes: ${toJSON onlyDifference}."
            else
            "Expected ${toJSON expected}, got ${toJSON expression}.";
        in
        if expression == expected || (typeOf expected == "set" && length differenceSet == 0) then
          acc + 1
        else
          throw "Test ${toString (acc+1)} failed: '${description}'. ${mismatchString}."
      ) 0
      testCases;
}
