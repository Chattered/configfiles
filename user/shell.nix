{ pkgs ? (import <nixpkgs> {}).pkgs
}:
{
   emacs =
     let
       myemacs =
         with pkgs.emacsPackages; with pkgs.emacsPackagesNg; pkgs.emacsWithPackages
         [ ace-jump-mode cl-lib helm-projectile magit org paredit pdf-tools w3m
           ghc-mod haskell-mode haskellMode twittering-mode undo-tree
         ];
       myhaskell = pkgs.haskellPackages.ghcWithPackages (p: with p; [
         cabal-install ghc-mod parallel QuickCheck semigroups turtle xml
       ]);
     in pkgs.stdenv.mkDerivation {
       name = "emacs";
       buildInputs = [ myemacs myhaskell pkgs.mu pkgs.offlineimap ];
       shellHook = ''
         export TZ="Europe/London"
         if [[ ! -e $TMP/emacs$UID/server ]]
         then
           emacs --daemon --eval "(progn\
             (push \"${pkgs.mu}/share/emacs/site-lisp/mu4e\" load-path)\
             (load-file \"mu4e.el\")\
             (org-babel-load-file\
                (expand-file-name \"emacs-init.org\" (getenv \"HOME\")))\
             (switch-to-buffer \"*scratch*\")\
             (require 'helm-config)
       (paredit-mode))"
         fi
       '';
     };
   media =
     with pkgs; stdenv.mkDerivation {
       name = "media";
       buildInputs = [ ffmpeg vlc youtube-dl mplayer ];
     };
}
