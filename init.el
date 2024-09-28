;; schutte-macs 🛸
;; ---
;; ok here goes

;; first, set up the package manager
;; ---

(require 'package)
(require 'use-package)

;; the package manager is built in, but by default only references GNU repos
;; melpa is the de-facto community package repository
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; configurae the use-package macro to ensure the package is installed if missing
(setq use-package-always-ensure t)

;; and make sure we can load our own code too
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))
(require 'schutte)


;; ---------------
;; now, set some defaults
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

;; by default, the project manager only considers VC-backed directory to be a project
;; but we like having project stuff when there's just a package file too

(require 'project)
(add-to-list 'project-vc-extra-root-markers "requirements.txt")
(add-to-list 'project-vc-extra-root-markers "package.json")
(add-to-list 'project-vc-extra-root-markers "Gemfile")

;; which-key shows a popup with info if emacs is waiting for another keystroke
;; improves discoverability 100000x
(use-package which-key
  :config (which-key-mode))

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


;; ---------------
;; next up, make it pretty
;; generally, I want it close to defaults and relaxed

;; change themes with M-x customize-themes
(use-package ef-themes)
(use-package modus-themes)

;; add some window padding; much less old-school feeling
(use-package spacious-padding)

;; get nice vertical minibuffer completion
(use-package vertico
  :config (vertico-mode))

;; add nice additional details to minibuffer completion candidates
(use-package marginalia
  :config (marginalia-mode))

;; get popups for completion on tab (when the mode supports it, through LSP likely)
(use-package corfu
  :config
  (global-corfu-mode)
  :init
  (require 'corfu-popupinfo)
  (corfu-popupinfo-mode))

;; make completion tolerant of different search styles
;; in particular, match on chunks in any order, and allow searching by initials
(use-package orderless
  :custom
  (completion-styles '(orderless initials basic)))

;; adds better syntax highlighting to dired buffers
(use-package diredfl)


;; ---------------
;; next up, make it a great code oditor
;;
;; emacs core includes tree-sitter (for parsing from upstream
;; grammars), and LSP, but the in-core LSP client is somewhat limited
;; in features. (actually, it's just that it leaves UI up to existing
;; emacs features, but they weren't designed together).
;;
;; lsp-mode is an alternative, which we get transitively through
;; lsp-ui, which provides a more vscode like experience out of the box
;;
;; tree-sitter is a library for building parsers, and these days
;; powers most good programming syntax modes. treesit-auto will
;; attempt to automatically install a grammar when opening a file that
;; has a treesit mode but no installed grammar.

(use-package lsp-ui
  :hook (prog-mode . lsp))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; polymode make emacs better able to handle modes with mixed syntax
;; such as HTML+script+css, or ruby+SQL
(use-package polymode)


;; ---------------
;; next up, make it an e-vi-l editor
;;
;; evil-mode provides really good vim bindings; they are only enabled
;; in text-editing modes though, because I find they conflict too much
;; elsewhere.
;;
;; if you're interested in using them more fully, see
;; ~evil-collection~ in the package list

(use-package evil
  :hook ((prog-mode . evil-local-mode)
	 (text-mode . evil-local-mode)
	 (wdired-mode . evil-local-mode)))

;; comment motions
(use-package evil-commentary
  :config (evil-commentary-mode))

;; change around/inside surrounding delimiters
(use-package evil-surround
  :config (global-evil-surround-mode))


;; ---------------
;; next up, install some other cool apps

;; magit is the best git client you've ever used
(use-package magit
  :hook
  ;; in the buffer showing git output, make URLS clickable
  (magit-process-mode . goto-address-mode)

  :bind
  (:map project-prefix-map
	("m" . magit-project-status)))

;; eat is a surprisingly good terminal emulator
(use-package eat
  :config
  (setq eat-kill-buffer-on-exit t)

  :bind
  (:map project-prefix-map
	("t" . eat-project-other-window)))


;; ---------------
;; lastly, these custom variables were set by the `customize` functionality
;; be careful editing these by hand, and recognize that emacs will write to these when shutting down

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
