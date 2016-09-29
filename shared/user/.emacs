(add-hook 'after-init-hook
          (lambda ()
            (when (equal (getenv "emacsserver") "1")
              (push (getenv "mu4ePath") load-path)
              (load-file "mu4e.el")
              (org-babel-load-file
                (expand-file-name "server-init.org" user-emacs-directory)))
            (org-babel-load-file
             (expand-file-name "shared-init.org" user-emacs-directory))))
