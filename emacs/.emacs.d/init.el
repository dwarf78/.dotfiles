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


;; Expand myinit.org
(org-babel-load-file (expand-file-name "~/.emacs.d/Emacs.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(simple-httpd websocket org-roam-server org-roam diminish yasnippet-snippets which-key visual-fill-column use-package spacemacs-theme spaceline smartparens rmsbolt rainbow-mode rainbow-delimiters pretty-mode org-bullets multiple-cursors mark-multiple magit linum-relative ivy-rich helpful ggtags general flycheck-clang-analyzer doom-themes doom-modeline dashboard counsel-projectile company-irony company-c-headers command-log-mode beacon ace-window)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.05))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.1))))
 '(org-level-6 ((t (:inherit outline-5 :height 1.1))))
 '(org-level-7 ((t (:inherit outline-5 :height 1.1))))
 '(org-level-8 ((t (:inherit outline-5 :height 1.1)))))
