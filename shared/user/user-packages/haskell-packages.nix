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
        sha256 = "0l253913g1bwq8lr1n9ch8il7d7z9bf1ddgav1gfvj4mdvpncvjz";
      };
      libraryHaskellDepends = [
        array base binary comonad containers free mtl parsec QuickCheck
        semigroupoids semigroups semiring-simple transformers
      ];
      description = "Ad-hoc utilities.";
      license = stdenv.lib.licenses.mit;
    };
}
