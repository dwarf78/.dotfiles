;; Remove the startup page
(setq inhibit-startup-message t)

;; Set up the visible bell
(setq visible-bell t)

(scroll-bar-mode -1)			;Disable scroll bar
(tool-bar-mode -1)			;Disable the toolbar 
(tooltip-mode 1)			;Disable tooltip
(set-fringe-mode 10)			;Give some breathing room

(menu-bar-mode -1)			;Disable the menu bar
(load-theme 'wombat)			;Setup theme

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialized use package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Allow to show you typed commands
(use-package command-log-mode)

;; Display line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook		
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Rainbow delimiters *emacs-lisp*
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
	     
;; Ivy setup
(use-package ivy
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

;; Doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

;; Which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))
