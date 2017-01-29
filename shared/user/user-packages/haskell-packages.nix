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
        sha256 = "1f4dvnnvbwqa4kqi5fydq6h0g25cf54sffi80xq2dqwcfnh61qnq";
      };
      libraryHaskellDepends = [
        array base binary comonad containers free mtl parsec QuickCheck
        semigroupoids semigroups semiring-simple transformers
      ];
      description = "Ad-hoc utilities.";
      license = stdenv.lib.licenses.mit;
    };
}
