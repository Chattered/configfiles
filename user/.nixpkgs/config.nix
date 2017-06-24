{ pkgs }:
let userPackages = import <userpackages>;
in rec {
  allowUnfree = true;
  haskellPackageOverrides = self: super:
    pkgs.lib.mapAttrs (n: v: self.callPackage v {}) userPackages.haskellPackages // {
     pipes-binary = pkgs.haskell.lib.dontCheck super.pipes-binary;
  };

  packageOverrides = pkgs:
    let userpkgs =
      pkgs.lib.mapAttrs (n: v: pkgs.callPackage v {}) userPackages.packages;
    in rec {
      mkOcamlPackages = ocaml:
        pkgs.ocaml-ng.mkOcamlPackages ocaml
          (self: super: pkgs.lib.mapAttrs (n: v: pkgs.newScope self v {})
                                          userPackages.ocamlPackages);
      torbrowser = pkgs.torbrowser.overrideDerivation (super: rec {
        version = "6.0.8";
        src = pkgs.fetchurl {
         url = "https://archive.torproject.org/tor-package-archive/torbrowser/${version}/tor-browser-linux${if pkgs.stdenv.is64bit then "64" else "32"}-${version}_en-US.tar.xz";
         sha256 = if pkgs.stdenv.is64bit then
           "1s2yv72kj4zxba0850fi1jv41c69vcw3inhj9kqhy1d45ql7iw0w" else
           "0zvqf444h35ikv1f3nwkh2jx51zj5k9w4zdxx32zcrnxpk5nhn97";
        };
      });
      emacs25 = pkgs.emacs25.override {
        withGTK2 = false;
        withGTK3 = false;
      };
      emacsPackagesNg = pkgs.emacsPackagesNg.override (super: self: {
          twittering-mode = self.melpaPackages.twittering-mode;
          # This is the melpa package as defined in nixpkgs master. We can change to
          # w3m = self.melpaPackages.w3m once it makes it into unstable.
          w3m = self.callPackage ({ fetchFromGitHub, fetchurl, lib, melpaBuild }:
            melpaBuild {
                pname = "w3m";
                version = "20121224.2047";
                src = fetchFromGitHub {
                  owner = "emacsorphanage";
                  repo = "w3m";
                  rev = "5986b51c7c77500fee3349fb0b3f4764d3fc727b";
                  sha256 = "1lgvdaghzj1fzh8p6ans0f62zg1bfp086icbsqmyvbgpgcxia9cs";
                };
                recipeFile = fetchurl {
                  url = "https://raw.githubusercontent.com/milkypostman/melpa/50e8d089f4e163eb459fc602cb90440b110b489f/recipes/w3m";
                  sha256 = "0vh882b44vxnij3l01sig87c1jmbymgirf6s98mvag1p9rm8agxw";
                  name = "w3m";
                };
                packageRequires = [ pkgs.w3m ];
                meta = {
                  homepage = "https://melpa.org/#/w3m";
                  license = lib.licenses.free;
                };
              }) {};
        });
      mu = pkgs.mu.override { withMug = false; };
    } // userpkgs;
}
