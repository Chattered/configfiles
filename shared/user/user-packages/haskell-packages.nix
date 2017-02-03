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
        sha256 = "14k6s5h7c8cgz7q54vlgw9hpb5hlnp8dirzihzjm8pp4f6laywa2";
      };
      libraryHaskellDepends = [
        array base binary comonad containers free mtl parsec QuickCheck
        semigroupoids semigroups semiring-simple transformers
      ];
      description = "Ad-hoc utilities.";
      license = stdenv.lib.licenses.mit;
    };
}
