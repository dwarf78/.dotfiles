;;; Setup package manager
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")
			 ))
(package-initialize)

;;; Bootstrap 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure 't)

;; Avoid been prompted to follow link
(setq vc-follow-symlinks t)

;;; Tell emacs where is your personal elisp lib dir
(add-to-list 'load-path "~/.emacs.d/lisp/")

;;; Config file via org-babel
(when (file-readable-p "~/.emacs.d/config.org")
  (org-babel-load-file (expand-file-name "~/.emacs.d/config.org")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(memoize unicode-fonts elfeed-org cmake-mode yasnippet-snippets which-key use-package undo-tree try tron-legacy-theme smartparens rainbow-delimiters pocket-reader page-break-lines org-superstar org-roam-ui org-bullets org-appear olivetti multiple-cursors minimap magit linum-relative ivy-rich helpful flycheck-clang-analyzer elfeed doom-themes doom-modeline diminish deft dashboard counsel-projectile company-tabnine company-bibtex beacon all-the-icons-ivy all-the-icons-dired ace-window)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
