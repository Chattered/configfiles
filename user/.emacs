(add-hook 'after-init-hook
          (lambda ()
            (org-babel-load-file
             (expand-file-name "shared-init.org" user-emacs-directory))))
