{ pkgs ? (import <nixpkgs> {}).pkgs
}:
{
   emacs = 
     let myemacs =
       with pkgs.emacsPackages; with pkgs.emacsPackagesNg; with pkgs.emacsMelpa; pkgs.emacsWithPackages
       [ cl-lib helm-projectile magit org paredit twittering-mode ];
     in pkgs.stdenv.mkDerivation {
       name = "emacs";
       buildInputs = [ myemacs pkgs.mu pkgs.offlineimap ];
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
}
