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

;; ;; remove-dos-eol
;; (add-hook 'elfeed-show-mode-hook 'remove-dos-eol)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline success warning error])
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))
 '(chart-face-color-list
   '("#705c3c" "#4f666f" "#c1c00a" "#2fafef" "#7f7f8e" "#376f9a"
     "#504420" "#204840" "#6f6f00" "#1f2f8f" "#4f4f5f" "#00404f"))
 '(custom-safe-themes
   '("35335d6369e911dac9d3ec12501fd64bc4458376b64f0047169d33f9d2988201"
     "30dc9873c16a0efb187bb3f8687c16aae46b86ddc34881b7cae5273e56b97580"
     "896e4305e7c10f3217c5c0a0ef9d99240c3342414ec5bfca4ec4bff27abe2d2d"
     "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2"
     "250007c5ae19bcbaa80e1bf8184720efb6262adafa9746868e6b9ecd9d5fbf84"
     "251ed7ecd97af314cd77b07359a09da12dcd97be35e3ab761d4a92d8d8cf9a71"
     "944d52450c57b7cbba08f9b3d08095eb7a5541b0ecfb3a0a9ecd4a18f3c28948"
     "dde643b0efb339c0de5645a2bc2e8b4176976d5298065b8e6ca45bc4ddf188b7"
     "bfc0b9c3de0382e452a878a1fb4726e1302bf9da20e69d6ec1cd1d5d82f61e3d"
     default))
 '(flymake-error-bitmap '(flymake-double-exclamation-mark modus-themes-intense-red))
 '(flymake-note-bitmap '(exclamation-mark modus-themes-intense-cyan))
 '(flymake-warning-bitmap '(exclamation-mark modus-themes-intense-yellow))
 '(highlight-changes-colors nil)
 '(highlight-changes-face-list '(success warning error bold bold-italic))
 '(hl-todo-keyword-faces
   '(("HOLD" . "#dfaf7a") ("TODO" . "#fec43f") ("NEXT" . "#c6daff")
     ("THEM" . "#c6daff") ("PROG" . "#2fafff") ("OKAY" . "#2fafff")
     ("DONT" . "#dfaf7a") ("FAIL" . "#fec43f") ("BUG" . "#fec43f")
     ("DONE" . "#2fafff") ("NOTE" . "#dfaf7a") ("KLUDGE" . "#dfaf7a")
     ("HACK" . "#dfaf7a") ("TEMP" . "#dfaf7a") ("FIXME" . "#fec43f")
     ("XXX+" . "#fec43f") ("REVIEW" . "#2fafff")
     ("DEPRECATED" . "#2fafff")))
 '(ibuffer-deletion-face 'modus-themes-mark-del)
 '(ibuffer-filter-group-name-face 'bold)
 '(ibuffer-marked-face 'modus-themes-mark-sel)
 '(ibuffer-title-face 'default)
 '(ispell-dictionary nil)
 '(markdown-command "/usr/bin/pandoc" t)
 '(org-src-block-faces 'nil)
 '(package-selected-packages
   '(ace-window all-the-icons-dired all-the-icons-ivy beacon cmake-mode
		company-bibtex company-tabnine copilot
		counsel-projectile dashboard deft diminish
		doom-modeline doom-themes elfeed-org
		flycheck-clang-analyzer flymd helpful impatient-mode
		ivy-rich linum-relative magit markdown-mode memoize
		minimap modus-themes multiple-cursors nasm-mode
		olivetti org-appear org-bullets org-modern org-roam-ui
		org-superstar page-break-lines pocket-reader
		rainbow-delimiters smartparens try undo-tree
		vs-dark-theme vscode-icon x86-lookup
		yasnippet-snippets))
 '(rcirc-colors
   '(modus-themes-fg-red modus-themes-fg-green modus-themes-fg-blue
			 modus-themes-fg-yellow
			 modus-themes-fg-magenta modus-themes-fg-cyan
			 modus-themes-fg-red-warmer
			 modus-themes-fg-green-warmer
			 modus-themes-fg-blue-warmer
			 modus-themes-fg-yellow-warmer
			 modus-themes-fg-magenta-warmer
			 modus-themes-fg-cyan-warmer
			 modus-themes-fg-red-cooler
			 modus-themes-fg-green-cooler
			 modus-themes-fg-blue-cooler
			 modus-themes-fg-yellow-cooler
			 modus-themes-fg-magenta-cooler
			 modus-themes-fg-cyan-cooler
			 modus-themes-fg-red-faint
			 modus-themes-fg-green-faint
			 modus-themes-fg-blue-faint
			 modus-themes-fg-yellow-faint
			 modus-themes-fg-magenta-faint
			 modus-themes-fg-cyan-faint
			 modus-themes-fg-red-intense
			 modus-themes-fg-green-intense
			 modus-themes-fg-blue-intense
			 modus-themes-fg-yellow-intense
			 modus-themes-fg-magenta-intense
			 modus-themes-fg-cyan-intense)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
