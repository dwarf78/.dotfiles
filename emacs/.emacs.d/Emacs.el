;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "*** Emacs loaded in %s with %d garbage collections."
		     (format "%.2f seconds"
			     (float-time
			      (time-subtract after-init-time before-init-time)))
		     gcs-done)))

(use-package diminish
  :ensure t)

(use-package super-save
  :ensure t
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq display-time-24hr-format t)
(setq display-time-format "%H:%M - %d %B %Y")

(global-set-key (kbd "C-x b") 'ibuffer)

(display-time)
(global-font-lock-mode t)
(setq visible-bell t)     
(setq inhibit-startup-message t)
;; (global-display-line-numbers-mode t)
(column-number-mode)
(tool-bar-mode -1)  
(scroll-bar-mode -1)
(set-fringe-mode 10)
;; (setq font-lock-maximum-decoration t)
(show-paren-mode t)
(use-package linum-relative
  :ensure t
  :diminish
  :config
  (setq linum-relative-current-symbol "")
  (add-hook 'prog-mode-hook 'linum-relative-mode))
(setq linum-relative-backend 'display-line-numbers-mode)
;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook		
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Rainbow delimiters *emacs-lisp*
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package spacemacs-theme
       :ensure t
       :defer t
        :init (load-theme 'spacemacs-dark t))
   ;; Doom themes
(use-package doom-themes
  :ensure t
  :init (load-theme 'spacemacs-dark t))

;; Doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

;; Install all icons
(use-package all-the-icons)

(use-package emojify
  :ensure t
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(defun dw/replace-unicode-font-mapping (block-name old-font new-font)
  (let* ((block-idx (cl-position-if
                         (lambda (i) (string-equal (car i) block-name))
                         unicode-fonts-block-font-mapping))
         (block-fonts (cadr (nth block-idx unicode-fonts-block-font-mapping)))
         (updated-block (cl-substitute new-font old-font block-fonts :test 'string-equal)))
    (setf (cdr (nth block-idx unicode-fonts-block-font-mapping))
          `(,updated-block))))

(use-package unicode-fonts
  :ensure t
  :disabled
  :if (not dw/is-termux)
  :custom
  (unicode-fonts-skip-font-groups '(low-quality-glyphs))
  :config
  ;; Fix the font mappings to use the right emoji font
  (mapcar
    (lambda (block-name)
      (dw/replace-unicode-font-mapping block-name "Apple Color Emoji" "Noto Color Emoji"))
    '("Dingbats"
      "Emoticons"
      "Miscellaneous Symbols and Pictographs"
      "Transport and Map Symbols"))
  (unicode-fonts-setup))

(defun efs/org-mode-setup ()
      (org-indent-mode)
      (variable-pitch-mode 1)		
      (auto-fill-mode 0)
      (visual-line-mode 1)
      (diminish org-indent-mode))

    ;; Set the variable pitch face
    (set-face-attribute 'variable-pitch nil
                        :family "Liberation Serif"
                        ;; :height (dw/system-settings-get 'emacs/variable-face-size)
                        ;; :weight 'light
                        )
    ;; Set the fixed pitch face
    (set-face-attribute 'fixed-pitch nil
                        :family "Liberation Mono"
                        ;; :weight 'light
                        ;; :height (dw/system-settings-get 'emacs/fixed-face-size))
                        )
    ;; Make sure org-indent face is available
    (require 'org-indent)

    (use-package org
:ensure t
      :hook (org-mode . efs/org-mode-setup)
      :config
      (setq org-ellipsis " ▾"))

    (defun efs/org-font-setup ()
      ;; Replace list hyphen with dot
      (font-lock-add-keywords 'org-mode
                              '(("^ *\\([-]\\) "
                                 (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))

    ;; Org-mode stuff
    (use-package org-bullets
      :ensure t
      :config
      (add-hook 'org-mode-hook 'org-bullets-mode)

      :custom
      (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))
    ;; Org-mode activation
    (global-set-key (kbd "C-c l") 'org-store-link)
    (global-set-key (kbd "C-c a") 'org-agenda)
    (global-set-key (kbd "C-c c") 'org-capture)

    ;; Hide the emphasis markup (e.g. /.../ for italics, *...* for bold, etc.)
    (setq org-hide-emphasis-markers t)


    (custom-set-faces
     '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
     '(org-level-2 ((t (:inherit outline-2 :height 1.1))))
     '(org-level-3 ((t (:inherit outline-3 :height 1.05))))
     '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
     '(org-level-5 ((t (:inherit outline-5 :height 1.1))))
     '(org-level-6 ((t (:inherit outline-5 :height 1.1))))
     '(org-level-7 ((t (:inherit outline-5 :height 1.1))))
     '(org-level-8 ((t (:inherit outline-5 :height 1.1))))
     )

    ;; ;; Load old easy template

    (require 'org-tempo)

;; (use-package rainbow-mode
;;   :ensure t
;;   :init
;;   (add-hook 'prog-mode-hook 'rainbow-mode))

(use-package 
  rainbow-delimiters
  :ensure t
  :init
    (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(when window-system (add-hook 'prog-mode-hook 'hl-line-mode))

; flashes the cursor's line when you scroll
     (use-package beacon
     :ensure t
     :config
     (beacon-mode 1)
     ;(setq beacon-color "#666600")
     )

(when window-system
  (use-package all-the-icons
    :ensure t
    :init
    )
;; (all-the-icons-install-fonts t)		
)

(when window-system (use-package dashboard
    :ensure t
    :config
      (dashboard-setup-startup-hook)
      (setq dashboard-startup-banner 'logo)
      (setq dashboard-center-content t)
      (setq dashboard-set-heading-icons t)
      (setq dashboard-set-file-icons t)
      (setq dashboard-items '((recents  . 5)
			      (projects . 5)))
      (setq dashboard-banner-logo-title ""))
)

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "SPC") #'company-abort))

(use-package ace-window
 :ensure t
 :init
 (progn
 (setq aw-scope 'global) ;; was frame
 (global-set-key (kbd "C-x O") 'other-frame)
   (global-set-key [remap other-window] 'ace-window)
   (custom-set-faces
    '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0))))) 
   ))

(use-package ivy
     :ensure t
           :diminish
       :bind(("C-s" . swiper)
             :map ivy-minibuffer-map
             ("TAB" . ivy-alt-done)
             ("C-l" . ivy-alt-done)
             ("C-j" . ivy-next-line)
             ("C-k" . ivy-previous-line)
             :map ivy-switch-buffer-map
             ("C-k" . ivy-previous-line)
             ("C-l" . ivy-done)
             ("C-d" . ivy-switch-buffer-kill)
             :map ivy-reverse-i-search-map  
             ("C-k" . ivy-previous-line)
             ("C-d" . ivy-reverse-isearch-kill))
       :config
       (ivy-mode 1))

     ;; Ivy mode rich
     (use-package ivy-rich
:ensure t
       :init
       (ivy-rich-mode 1))

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-X C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package which-key
  :ensure t
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package helpful
  :ensure t
 :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package avy
  :ensure t
  :bind
    ("M-s" . avy-goto-char-2))

(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(defun config-visit ()
  (interactive)
  (find-file "~/.emacs.d/Emacs.org"))
(global-set-key (kbd "C-c e") 'config-visit)

(defun config-reload ()
  "Reloads ~/.emacs.d/config.org at runtime"
  (interactive)
  (org-babel-load-file (expand-file-name "~/.emacs.d/Emacs.org")))
(global-set-key (kbd "C-c r") 'config-reload)

(defalias 'yes-or-no-p 'y-or-n-p)

(use-package ggtags
:ensure t
:config 
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))
)

(add-hook 'c++-mode-hook 'yas-minor-mode)
(add-hook 'c-mode-hook 'yas-minor-mode)

(use-package flycheck-clang-analyzer
  :ensure t
  :config
  (with-eval-after-load 'flycheck
    (require 'flycheck-clang-analyzer)
     (flycheck-clang-analyzer-setup)))

(with-eval-after-load 'company
  (add-hook 'c++-mode-hook 'company-mode)
  (add-hook 'c-mode-hook 'company-mode))

(use-package company-c-headers
  :ensure t)

(use-package company-irony
  :ensure t
  :config
  (setq company-backends '((company-c-headers
                            company-dabbrev-code
                            company-irony))))

(use-package irony
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package flycheck
:ensure t
:init
(global-flycheck-mode t))

(use-package yasnippet
  :ensure t
:diminish
  :config
  (use-package yasnippet-snippets
  :ensure t)
  (yas-global-mode 1))

(use-package smartparens
 :ensure t
   :hook (prog-mode . smartparens-mode)
   :custom
   (sp-escape-quotes-after-insert nil)
   :config
   (require 'smartparens-config))

(use-package projectile
       :ensure t
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :ensure t
  :config (counsel-projectile-mode))

;; (use-package mark-multiple
;;   :ensure t
;;   :bind ("C-c q" . 'mark-next-like-this))

;; obsolete. replaced by multicursor

(use-package multiple-cursors
  :ensure t
  :init 
  :bind (("C-S-c C-S-c" . 'mc/edit-lines)
	 ("C-> " . 'mc/mark-next-like-this)
	 ("C-< " . 'mc/mark-previous-like-this)
	 ("C-S-c C-S-a" . 'mc/mark-all-like-this)
	  ))

(defvar my-term-shell "/bin/zsh")
(defadvice ansi-term (before force-zsh)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

(use-package rmsbolt
  :ensure t
 :bind ("C-c C-c a" . 'rmsbolt-starter)
       )

(use-package magit
  :ensure t
  :config
  (setq magit-push-always-verify nil)
  (setq git-commit-summary-max-length 50)
  :bind
  ("C-x g" . magit-status))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Documents/org/Roam")
  (org-roam-completion-everywhere t)
:bind (("C-c n l" . org-roam-buffer-toggle)
       ("C-c n f" . org-roam-node-find)
       ("C-c n i" . org-roam-node-insert)
:map org-mode-map
("C-M-i" . completion-at-point))
:config
(org-roam-setup))
