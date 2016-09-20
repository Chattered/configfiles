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
        sha256 = "04wi0gb2c07zbh5n7v88345jyr8kxcrg1d7nkazjsdk03kwm26ma";
      };
      libraryHaskellDepends = [
        array base binary comonad containers free mtl parsec QuickCheck
        semigroupoids semigroups semiring-simple transformers
      ];
      description = "Ad-hoc utilities.";
      license = stdenv.lib.licenses.mit;
    };
}
