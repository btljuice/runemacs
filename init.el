;; Based on YouTube's System Crafters / Emacs From Scratch
;; https://www.youtube.com/watch?v=74zOY-vgkyw&list=PLEoMzSkcN8oPH1au7H6B7bBJ4ZO7BXjSZ
;; https://github.com/daviwil/dotfiles/blob/master/Emacs.org#package-management
;; Thank you!
;; N.B. rune abbreviation is for "runemacs"

;;;; Code: UI
(setq inhibit-startup-message t)
(scroll-bar-mode -1)  ; Disable visible scrollbar
(tool-bar-mode -1)    ; Disable toolbar
(menu-bar-mode -1)    ; Disable menu-bar
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120) ; Default font
(load-theme 'wombat) ; Default theme

;; Line Numbers
;; TODO Configure a toggle keybinding
(column-number-mode)
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;;; Section: Initialize package system
(require 'package) ; emacs package system
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents)) ; Updates the packages list if it's empty
					                     ; This process can be done manually through M-x list-packages then 'U'
(unless (package-installed-p 'use-package) (package-install 'use-package)) ; Install use-package for the first time
(require 'use-package) ; package helper
; (setq use-package-verbose t) ; Uncomment to PROFILE packages loaded at startup
(setq use-package-always-ensure t) ; Makes sure all packages are downloaded when a use-package form is evaluated

;;;; Fuzzy find completion framework
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
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
              ("C-d" . ivy-reverse-i-search-kill))
  :config (ivy-mode 1))

(use-package ivy-rich  ; enrich how ivy is displayed
  :init (ivy-rich-mode 1))

(use-package counsel  ; companion to ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
              ("C-r" . 'counsel-minibuffer-history))
  :config (setq ivy-initial-inputs-alist nil)) ; Don't start searches with ^

;;;; General
(use-package undo-tree
  :init (global-undo-tree-mode 1))

;;;; UI packages
(use-package all-the-icons) ; Required icons for doom-modeline
                            ; First run: M-x all-the-icons-install-fonts
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;;; Discoverability
(use-package which-key ; To discover keybindings as they are typed
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 1))

(use-package helpful ; enhance emacs help
  :custom (counsel-describe-function-function #'helpful-callable)
          (counsel-describe-variable-function #'helpful-variable)
  :bind ([remap describe-function] . helpful-function)
        ([remap describe-symbol] . helpful-symbol)
        ([remap describe-variable] . helpful-variable)
        ([remap describe-command] . helpful-command)
        ([remap describe-key] . helpful-key))

;;;; Global key binding
(global-set-key (kbd "<escape>") 'keyboard-espace-quit)
;; (global-set-key (kbd "SPC b b") 'counsel-switch-buffer)

;;;; Evil and Keybindings
(use-package general
  :config (general-create-definer rune/leader-keys
            :keymaps '(normal insert visual emacs)
            :prefix "SPC"
            :global-prefix "C-SPC")
          (rune/leader-keys
           "t"  '(:ignore t :which-key "toggles")
           "tt" '(counsel-load-theme :which-key "choose theme")))

(defun rune/evil-hook ()
  (dolist (mode '(eshell-mode
                  git-rebase-mode
                  term-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :demand
  :init (setq evil-want-integration t)
        (setq evil-want-keybinding nil)
        (setq evil-want-C-u-scroll t)
        (setq evil-want-Y-yank-to-eol t)
        (setq evil-respect-visual-line-mode t)
        (setq evil-undo-system 'undo-tree)
  :hook (evil-mode . rune/evil-hook)
  :config (evil-mode 1)
          (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
          ;; Use visual line motions even outside of visual-line-mode buffers
          (evil-global-set-key 'motion "j" 'evil-next-visual-line)
          (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

          (evil-set-initial-state 'messages-buffer-mode 'normal)
          (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))
