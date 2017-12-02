{ pkgs }:
let userPackages = import <userpackages>;
in rec {
  haskellPackageOverrides = self: super:
    pkgs.lib.mapAttrs (n: v: self.callPackage v {}) userPackages.haskellPackages // {
     ghc-syb-utils = pkgs.haskell.lib.overrideCabal super.ghc-syb-utils {
       version = "0.2.3";
       sha256 = "0rxwdivpcppwzbqglbrz8rm9f4g1gmba9ij7p7aj3di9x37kzxky";
     };
  };

  packageOverrides = pkgs:
    let userpkgs =
      pkgs.lib.mapAttrs (n: v: pkgs.callPackage v {}) userPackages.packages;
    in rec {
      mkOcamlPackages = ocaml:
        pkgs.ocaml-ng.mkOcamlPackages ocaml
          (self: super: pkgs.lib.mapAttrs (n: v: pkgs.newScope self v {})
                                          userPackages.ocamlPackages);
      haskellPackagesProfiled = pkgs.haskellPackages.override (_: {
        overrides = self: super:
          haskellPackageOverrides self super //
          {
            mkDerivation = (expr:
              super.mkDerivation (expr // { enableLibraryProfiling = true; }));
          };
      });
      emacs25 = pkgs.emacs25.override {
        withGTK2 = false;
        withGTK3 = false;
      };
      emacsPackagesNg = pkgs.emacsPackagesNg.overrideScope (super: self: {
        twittering-mode = pkgs.emacsPackagesNg.melpaPackages.twittering-mode;
        w3m = pkgs.emacsPackagesNg.callPackage
         ({ fetchFromGitHub, fetchurl, lib, melpaBuild }:
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
