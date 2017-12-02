{ pkgs ? (import <nixpkgs> {}).pkgs
}:
{
   emacs =
     let
       myemacs =
         with pkgs.emacsPackages; with pkgs.emacsPackagesNg; pkgs.emacsWithPackages
         [ ace-jump-mode emms cl-lib helm-projectile magit org paredit
           pdf-tools w3m graphviz-dot-mode haskell-mode haskellMode
           twittering-mode undo-tree
         ];
       myhaskell = pkgs.haskellPackages.ghcWithPackages (p: with p; [
         cabal-install network parallel QuickCheck semigroups turtle xml
       ]);
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-small beamer wrapfig marvosym wasysym cm-super ifplatform xstring xcolor minted pgfgantt framed;
  };
     in pkgs.stdenv.mkDerivation {
       name = "emacs";
       buildInputs = [ myemacs myhaskell tex pkgs.graphviz
                       pkgs.mp3info pkgs.mplayer pkgs.mu
                       pkgs.offlineimap pkgs.pythonPackages.pygments
                       pkgs.vorbis-tools pkgs.youtube-dl ];
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
