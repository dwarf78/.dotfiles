;; My init.el
;; Setup package manager
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Bootstrap 'use-package'

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Tell emacs where is your personal elisp lib dir
(add-to-list 'load-path "~/.emacs.d/lisp/")


;; Expand myinit.org
(org-babel-load-file (expand-file-name "~/.emacs.d/myinit.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-line-numbers-type 'relative)
 '(display-time-mode t)
 '(font-use-system-font t)
 '(org-export-backends '(ascii beamer html icalendar latex md odt))
 '(package-selected-packages
   '(multiple-cursors multiple-cursor auctex compiler-explorer pyenv-mode virtualenvwrapper lsp-jedi lsp-ui lsp-mode company-jedi company-irony company-c-headers flycheck-clang-analyzer dashboard pretty-mode company-mode yasnippet-snippets use-package spacemacs-theme smartparens org-bullets magit ggtags flycheck counsel beacon ace-window))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Fira Code" :foundry "CTDB" :slant normal :weight normal :height 113 :width normal))))
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.0))))
 '(org-level-4 ((t (:inherit outline-4 :height 0.9))))
 '(org-level-5 ((t (:inherit outline-5 :height 0.8)))))
