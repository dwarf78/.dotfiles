
;; My init.el

;; Setup package manager
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Bootstrap 'use-package'

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Tell emacs where is your personal elisp lib dir
(add-to-list 'load-path "~/.emacs.d/lisp/")


;; Expand Emacs.org
(org-babel-load-file (expand-file-name "~/.emacs.d/Emacs.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(org-roam-bibtex yasnippet-snippets which-key vscode-dark-plus-theme use-package super-save spacemacs-theme spaceline-all-the-icons smartparens rmsbolt rainbow-delimiters pdf-tools org-superstar org-roam org-bullets org-appear olivetti multiple-cursors mode-icons mixed-pitch magit linum-relative helpful helm-bibtex ggtags flycheck-clang-analyzer emojify doom-modeline diminish deft dashboard counsel-projectile company-posframe company-irony company-c-headers beacon all-the-icons-ivy-rich ace-window)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
