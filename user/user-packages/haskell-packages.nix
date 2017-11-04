{
  "PhiledCommon" =
    { mkDerivation, array, base, binary, comonad, containers, free, fetchFromGitHub,
    mtl, parsec, QuickCheck, semigroupoids, semigroups, semiring-simple, stdenv,
    transformers }:
    mkDerivation {
      pname = "PhiledCommon";
      version = "0.1.0.0";
      src = fetchFromGitHub {
        owner = "Chattered";
        repo = "PhiledCommon";
        rev = "master";
        sha256 = "1zcwa11ai4xkg7snif6f029kfbci93dc7fdzbdpyxvwxygmbsxqf";
      };
      libraryHaskellDepends = [
        array base binary comonad containers free mtl parsec QuickCheck
        semigroupoids semigroups semiring-simple transformers
      ];
      description = "Ad-hoc utilities.";
      license = stdenv.lib.licenses.mit;
    };
}
