{ pkgs ? (import <nixpkgs> {}).pkgs
}:
{
   emacs =
     let
       myemacs =
         with pkgs.emacsPackages; with pkgs.emacsPackagesNg; pkgs.emacsWithPackages
         [ cl-lib helm-projectile magit org paredit pdf-tools w3m
           ghc-mod haskell-mode haskellMode twittering-mode ];
       myhaskell = pkgs.haskellPackages.ghcWithPackages (p: with p; [
         turtle ghc-mod QuickCheck
       ]);
     in pkgs.stdenv.mkDerivation {
       name = "emacs";
       buildInputs = [ myemacs myhaskell pkgs.mu pkgs.offlineimap ];
       shellHook = ''
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
