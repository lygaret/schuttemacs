;; ok here goes
;;
;; ---
;;
;; this file is _literally executed_ when emacs starts up
;;
;; important things emacs _is_:
;;
;; * a _mutable_ system, which _expects_ you to mutate it
;;     - meaning defining a function, or changing a setting, or setting a keybinding _changes_ the _running_ system
;;     - this is true in other editors too
;;         - but you feel it often in emacs, imo
;;     - eg; you can redefine any function, and in most cases, _lose the ability to reference the original_
;;         - dealing with this is easy though, because restarting emacs starts from scratch
;;             - see [the section about running as a server](#server) when things have settled
;;
;; what configuration means:
;;
;; - setting runtime variables
;; - installing packages, and setting them up
;; - defining callback functions
;;     - either as keybinds
;;     - or by hooking onto another function
;;

;; now set up the package manager
;; ---
;;
;; - 'package :: the built-in emacs library for managing packages
;; - 'use-package :: the built-in macro for easy package installation
;;     - basically lets you separate packages easily with lazy-loading

(require 'package)
(require 'use-package)

;; the package manager is built in, but by default only references GNU repos
;; melpa is the de-facto community package repository
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; configurae the use-package macro to ensure the package is installed if missing
(setq use-package-always-ensure t)

;; also allow requiring files from the `site-lisp` directory
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))

;; and bring in our runtime library of nice things
(require 'schutte)

;; by default, emacs packages dump temp files and such all over the place
;; no-littering overrides a bunch of variables from a bunch of packages to clean it up
;; and force files into semantically appropriate '/etc' and '/var' directories

(use-package no-littering
  :init
  (setq no-littering-etc-directory (schutte/emacsd-etc))
  (setq no-littering-var-directory (schutte/emacsd-var)))

(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq backup-directory-alist
      `(("." . ,(no-littering-expand-var-file-name "backups/"))))

;; configure the editor now!
;; ---
;;
;; let's start by setting some defaults
;; imo, these should be the defaults everywhere

;; this one is just dumb
;; this makes some prompts accept y/n instead of the full word yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; when a change occurs outside emacs, and the buffer is unmodified, reload it
(global-auto-revert-mode t)

;; allows single-key short cut handling for _some_ repeated actions
;; various packages can register with it
(repeat-mode)

;; clean up old buffers and such on a timer, if you've been running for a while
(midnight-mode)

;; dired should do `git mv`
(setq dired-vc-rename-file t)

;; use the tab key for indent then completion
(setq tab-always-indent 'complete)

;; don't require a project to be a git dir
(require 'project)
(add-to-list 'project-vc-extra-root-markers "requirements.txt")
(add-to-list 'project-vc-extra-root-markers "package.json")
(add-to-list 'project-vc-extra-root-markers "Gemfile")

;; prettiness is nice
;; two nice theme packs, find what you like with `M-x customize-themes`

(use-package ef-themes)
(use-package modus-themes)

;; add some window padding; much less old-school feeling
(use-package spacious-padding)

;; which-key shows a popup with info if emacs is waiting for another keystroke
;; improves discoverability 100000x
(use-package which-key
  :config (which-key-mode))

;; get nice vertical minibuffer completion
(use-package vertico
  :config (vertico-mode))

(use-package marginalia
  :config (marginalia-mode))

(use-package corfu
  :config (global-corfu-mode)
  :init
  (require 'corfu-popupinfo)
  (corfu-popupinfo-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless initials basic)))

;; load editor configuration from project path
(use-package editorconfig
  :config (editorconfig-mode))

;; this one is more fixing a mac problem;
;; Emacs.app starts in the shell env of the OS X user account, not whatever your shell
;; path is; this package provides `exec-path-from-shell-initialize, which starts a shell,
;; extracts `$PATH` and makes it emacs' path.
(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize))

;; allow zooming globally
(use-package default-text-scale
  :config (default-text-scale-mode))

;; clean up whitespace in changed lines
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;; emacs core includes tree-sitter (for parsing from upstream grammars), and LSP,
;; but the in-core LSP client is somewhat limited in features. (actually, it's just
;; that it leaves UI up to existing emacs features, but they weren't designed together).
;;
;; lsp-mode is an alternative, which we get transitively through lsp-ui, which provides
;; a more vscode like experience out of the box

(use-package evil
  :hook ((prog-mode . evil-local-mode)
	 (text-mode . evil-local-mode)
	 (wdired-mode . evil-local-mode)))

(use-package evil-commentary
  :config (evil-commentary-mode))

(use-package evil-surround
  :config (global-evil-surround-mode))

(use-package lsp-ui)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package polymode)

;; specific enhancements to specific functionality

;; adds better syntax highlighting to dired buffers
(use-package diredfl)

;; eat is a surprisingly good terminal emulator
(use-package eat
  :config
  (setq eat-kill-buffer-on-exit t)

  :bind
  (:map project-prefix-map
	("t" . eat-project-other-window)))

;; magit is the best git client you've ever used
(use-package magit
  ;; in the buffer showing git output, auto-link URLS (so you can click github PR links)
  :hook
  (magit-process-mode . goto-address-mode)

  :bind
  (:map project-prefix-map
	("m" . magit-project-status))

  :config
  (setq magit-clone-default-directory (schutte/homed "projects")))


;; the custom variables below were set by the `customize` functionality

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(ef-dream))
 '(custom-safe-themes
   '("c3e62e14eb625e02e5aeb03d315180d5bb6627785e48f23ba35eb7b974a940af"
     "daf189a2af425e9f376ddb9e99627e9d8f2ebdd5cc795065da81633f88389b4b"
     "87b82caf3ade09282779733fb6de999d683caf4a67a1abbee8b8c8018a8d9a6b"
     default))
 '(default-frame-alist '((ns-transparent-titlebar . t)))
 '(package-selected-packages nil)
 '(spacious-padding-mode t)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))

(put 'dired-find-alternate-file 'disabled nil)
