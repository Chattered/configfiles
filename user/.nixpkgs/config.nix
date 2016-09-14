{ pkgs }:
let userPackages = import <userpackages>;
in rec {
  allowUnfree = true;

  firefox = {
    enableAdobeFlash = true;
    enableAdobeFlashDRM = true;    
    icedtea = true;
    enableGoogleTalkPlugin = true;
  };

  chromium = {
    enablePepperFlash = true;
    enableWideVine = true;
    enablehiDPISupport = true;
  };

  haskellPackageOverrides = self: super:
    pkgs.lib.mapAttrs (n: v: self.callPackage v {}) userPackages.haskellPackages;

  packageOverrides = pkgs:
    let userpkgs =
      pkgs.lib.mapAttrs (n: v: pkgs.callPackage v {}) userPackages.packages;
    in rec {
      steam = pkgs.steam.override { newStdcpp = true; };
      mkOcamlPackages = ocaml: self:
        pkgs.mkOcamlPackages ocaml self
	// pkgs.lib.mapAttrs (n: v: pkgs.newScope self v {}) userPackages.ocamlPackages;
      emacs = pkgs.emacs.override { withGTK2 = false; };
    } // userpkgs;
}
