(require 'package)

(package-initialize)

(require 'use-package)

(use-package align
    :config
  (bind-key "C-x a r"       'align-regexp))

(use-package ag
    :config
  (setq ag-arguments
        '("--smart-case" "--nogroup" "--column" "--")
        ag-ignore-list
        '("*.js")))

(use-package browse-url
    :config
  (setq browse-url-browser-function
        'eww-browse-url
	browse-url-firefox-new-window-is-tab
        t))

(use-package bs
    :config
  (bind-key "M-SPC"         'bs-show))

(use-package dumb-jump)

(use-package cl)

(use-package company
    :config
  (bind-key "<s-tab>"       'company-complete))

(use-package dante
    :config
  (bind-key "<f4>"              'dante-set-lib)
  (bind-key "<f5>"              'dante-restart           dante-mode-map)

  (defun dante-set-full (x)
    (interactive "Mcabal target: ")
    (setf dante-repl-command-line `("cabal" "repl" ,x "-O0" "-j" "--builddir=dist-newstyle/dante")))

  (defun dante-set-lib (x)
    (interactive "Mcabal lib target: ")
    (dante-set-full (concat "lib:" x)))

  (defun dante-set-exe (x)
    (interactive "Mcabal exe target: ")
    (dante-set-full (concat "exe:" x)))

  (setq dante-repl-command-line
        '("cabal" "repl" "-O0" "-j" "--builddir=dist-newstyle/dante")
        dante-load-flags
        (quote
         ("+c" "-Wall" "-ferror-spans" "-Wwarn=missing-home-modules" "-fno-diagnostics-show-caret"))
        dante-methods-alist
        (quote
         ((new-build "cabal.project"
                     ("cabal" "repl" "-O0" "-j"
                              (or dante-target
                                  (dante-package-name)
                                  nil)
                              "--builddir=dist-newstyle/dante"))))))

(use-package dired
    :config
  (setq dired-listing-switches
        "-agGohF"
	dired-trivial-filenames
        "^\\.\\.?$\\|^#|hi$|dyn_hi$"))

(use-package flycheck
    :config
  (flycheck-add-next-checker 'haskell-dante 'haskell-hlint)
  (setq flycheck-checkers
        '(haskell-dante haskell-hlint)
        flycheck-highlighting-mode
        'sexps
        flycheck-hlint-language-extensions
        '(
          "BlockArguments"
          "GADTs"
          "LambdaCase"
          "MultiWayIf"
          "NumericUnderscores"
          "PatternSynonyms"
          "RankNTypes"
          "RecursiveDo"
          "TypeApplications"
          "TypeFamilies"
          )))

(use-package git-gutter-fringe
    :config
  (global-git-gutter-mode +1))

(use-package gnuplot
    :config
  (push '("\\.gnuplot$" . gnuplot-mode) auto-mode-alist))

(use-package haskell-mode
    :config
  (bind-key "M-p"                          'flycheck-previous-error)
  (bind-key "M-n"                          'flycheck-next-error)
  (bind-key "M-."                          'xref-find-definitions 'haskell-mode-map)

  (push (cons "\\.hs-boot\\'" 'haskell-mode) auto-mode-alist)

  (defun haskell-hook ()
    (message "******* 'haskell-hook' started")
    (form-feed-mode +1)
    (setf haskell-process-type 'cabal-repl)
    (dante-mode +1)
    (company-mode +1)
    (flycheck-mode +1)

    ;; Paredit is last, because unbalanced parens in comments break it.
    (paredit-mode +1)
    (message "....... 'haskell-hook' done"))

  (add-hook 'haskell-mode-hook             'haskell-hook)

  (setq haskell-hoogle-url
        "http://127.0.0.1:8080/?hoogle=%s"
        haskell-indentation-where-pre-offset
        1
        haskell-process-auto-import-loaded-modules
        t
        haskell-process-log
        t
        haskell-process-suggest-overloaded-strings
        nil
        haskell-process-suggest-remove-import-lines
        t
        haskell-process-suggest-restart
        nil
        haskell-process-type
        'cabal-repl))

(use-package helm-hoogle
    :config
  (bind-key "C-s-s"                        'helm-hoogle-at-point)

  (defun helm-hoogle-at-point ()
    (interactive)
    (helm :sources
          (helm-build-sync-source "Hoogle"
            :candidates #'helm-c-hoogle-set-candidates
            :action '(("Lookup Entry" . browse-url))
            :filtered-candidate-transformer (lambda (candidates source) candidates)
            :volatile t)
          :prompt "Helm hoogle: "
          :input (haskell-ident-at-point)
          :buffer "*Hoogle search*")))

(use-package helm
    :config
  (bind-key "<f1>"          'helm-apropos)
  (bind-key "C-x C-z"       'helm-resume)

  (setq helm-candidate-number-limit
        500
	helm-ff-transformer-show-only-basename
        nil
	helm-split-window-default-side
        'right))

(use-package helm-grepint
    :config
  (bind-key "M-s"           'helm-grepint-grep-root)

  (helm-grepint-set-default-config)

  (helm-grepint-add-grep-config agr
    :command "ag"
    :arguments "--nocolor --nogroup"
    :ignore-case-arg "--ignore-case"
    :root-directory-function helm-grepint-git-grep-locate-root)
  (helm-grepint-add-grep-config aghs
    :command "ag"
    :arguments "--nocolor --nogroup --haskell"
    :ignore-case-arg "--smart-case"
    :root-directory-function helm-grepint-git-grep-locate-root)

  (setq helm-grepint-grep-list
        '(agr aghs)))

(use-package helm-ls-git
    :config
  (bind-key "`"             'helm-ls-git-ls)

  (setq helm-ls-git-show-abs-or-relative
        'relative))

(use-package helm-config)

(use-package helm-descbinds)

(use-package helm-helm-commands)

(use-package ibuffer
    :config
  (bind-key "M-S-SPC"       'ibuffer)

  (setq ibuffer-default-sorting-mode
        'recency))

(use-package magit
    :config
  (bind-key "<menu>"        'magit-status)
  (bind-key "<print>"       'magit-status)
  (bind-key "C-x C-c"       'magit-commit)

  (setq git-commit-fill-column
        80
	git-commit-summary-max-length
        80
	magit-diff-refine-hunk
        t
        magit-log-arguments
        '("--graph" "--color" "--decorate" "--show-signature")
	magit-log-auto-more
        t
	magit-log-cutoff-length
        100
	magit-log-format-graph-function
        'magit-log-format-unicode-graph
	magit-log-margin-spec
        '(25 7 magit-duration-spec)
	magit-log-show-margin
        t
	magit-use-overlays
        nil))

(use-package mouse
    :config
  (setq mouse-autoselect-window
        t
	mouse-scroll-delay
        0.01))

(use-package msb
    :config
  (msb-mode +1)

  (setq msb-display-most-recently-used
        0
	msb-max-file-menu-items
        20))

(use-package mwheel
    :config
  (setq mouse-wheel-follow-mouse
        t
	mouse-wheel-mode
        t
	mouse-wheel-progressive-speed
        nil
	mouse-wheel-scroll-amount
        '(1)))

(use-package neotree
    :config
  (bind-key "C-<prior>"     (lambda () (interactive) (neotree-tab-move nil)))
  (bind-key "C-<next>"      (lambda () (interactive) (neotree-tab-move t)))

  (defun neotree-select ()
    (interactive)
    (funcall (cdr (assoc 97 (rest neotree-mode-map)))))

  (defun neotree-selected-dir-p ()
    (file-directory-p (neo-buffer--get-filename-current-line)))

  (defun neotree-window-p (win)
    (string= " *NeoTree*" (buffer-name (window-buffer win))))

  (defun maybe-select-neotree-window-p ()
    (cl-labels ((rec (init cur n)
                     (cond ((neotree-window-p cur)
                            (select-window cur)
                            t)
                           ((eq init cur)
                            nil)
                           (t
                            (rec init (next-window cur) (+ n 1))))))
      (rec (selected-window) (next-window (selected-window)) 0)))

  (defun neotree-tab-move (forward-p)
    (cond
      ((maybe-select-neotree-window-p)
       (if forward-p
           (neotree-next-line)
         (neotree-previous-line))
       (if (neotree-selected-dir-p)
           (other-window 1)
         (neotree-select)))
      (t
       nil)))

  (setq neo-autorefresh
        t
        neo-confirm-change-root
        'off-p
        neo-hidden-regexp-list
        '("^\\." "\\.pyc$" "~$" "^#.*#$" "\\.elc$" "\\.hi$" "\\.dyn_hi$" "\\.dyn_o$" "\\.o$" "\\.aux$" "CHANGELOG.md" "LICENSE" "Setup\\.hs" "Setup$" "^dist-newstyle" "\\.hi-boot$" "\\.o-boot$" "\\.dyn_hi-boot$")
        neo-hide-cursor
        nil
        neo-show-slash-for-folder
        nil
        neo-theme
        'ascii
        neo-window-width
        25)

  (neotree-toggle))

(use-package org
    :config
  (unbind-key "C-c C-r"                             org-mode-map)
  (bind-key "C-c a"         'org-agenda)
  (bind-key "C-c l"         'org-store-link)
  (bind-key "C-c r"         'org-remember)
  (bind-key "C-<tab>"       'other-window           org-mode-map)
  (bind-key "C-o"           (lambda ()
                              (interactive)
                              (org-open-at-point)
                              (scroll-up-line 20)
                              (other-window 1))
                                                    org-mode-map)
  (bind-key "C-c C-x C-x"   (lambda ()
                              (interactive)
                              (org-ctrl-c-ctrl-c)
                              (org-redisplay-inline-images))
                                                    org-mode-map)
  (bind-key "g"             (lambda ()
                              (interactive)
                              (revert-buffer nil t))
                                                    image-mode-map)

  (add-hook 'message-mode-hook                      'turn-on-orgstruct++)
  (add-hook 'org-mode-hook                          'auto-fill-mode)
  (add-hook 'org-shiftup-final-hook                 'windmove-up)
  (add-hook 'org-shiftleft-final-hook               'windmove-left)
  (add-hook 'org-shiftdown-final-hook               'windmove-down)
  (add-hook 'org-shiftright-final-hook              'windmove-right)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((gnuplot . t)))

  (setq org-blank-before-new-entry
        '((heading . auto) (plain-list-item))
        org-cycle-emulate-tab
        'exc-hl-bol
        org-confirm-babel-evaluate
        nil
        org-enforce-todo-checkbox-dependencies
        t
        org-enforce-todo-dependencies
        t
	org-hide-leading-stars
        t
        org-link-make-description-function
        'org-link-first-word
        org-list-allow-alphabetical
        t
	org-odd-levels-only
        t
	org-src-fontify-natively
        t
	org-src-preserve-indentation
        t
	org-src-tab-acts-natively
        t
	org-startup-with-inline-images
        t
	org-tags-column
        -120)

(defun org-id-find (id &optional markerp)
  "Return the location of the entry with the id ID.
The return value is a cons cell (file-name . position), or nil
if there is no entry with that ID.
With optional argument MARKERP, return the position as a new marker."
  (cond
   ((symbolp id) (setq id (symbol-name id)))
   ((numberp id) (setq id (number-to-string id))))
  (let ((remote-match (string-match "^file:\\([^:]+\\)\\(\\|:.+\\)$" id)))
    (if remote-match
        (let* ((file-raw2 (match-string 1 id))
               (table-id (match-string 2 id))
               (file-raw (org-table-formula-substitute-names file-raw2))
               (file (remove-if (lambda (c) (member c '(40 41))) file-raw)))
          (if (file-exists-p file)
              (let ((buffer (let ((query-about-changed-file nil))
                              (find-file-noselect file))))
                (unwind-protect
	            (with-current-buffer buffer
                      (beginning-of-buffer)
	              (let ((pos (progn
                                   (unless (string= table-id "")
                                     (let* ((ident (subseq table-id 1))
                                            (id-match (search-forward (concat "#+NAME: " ident) nil t)))
                                       (unless id-match
                                         (error "File \"%s\" has no table with NAME \"%s\"." file ident))
                                       (next-line)))
                                   (re-search-forward "^|-")
                                   (move-beginning-of-line nil))))
                        (cond
	                 ((null pos) nil)
	                 (markerp (move-marker (make-marker) pos buffer))
	                 (t (cons file pos)))))
	          ;; Remove opened buffer in the process.
	          (unless markerp (kill-buffer buffer))))
            (error "org-id-find:  reference to missing file %s" file)))
      (let ((file (org-id-find-id-file id))
	    org-agenda-new-buffers where)
        (when file
          (setq where (org-id-find-id-in-file id file markerp)))
        (unless where
          (org-id-update-id-locations nil t)
          (setq file (org-id-find-id-file id))
          (when file
	    (setq where (org-id-find-id-in-file id file markerp))))
        where))))

(defun org-table-get-remote-range (name-or-id form)
  "Get a field value or a list of values in a range from table at ID.

NAME-OR-ID may be the name of a table in the current file as set
by a \"#+NAME:\" directive.  The first table following this line
will then be used.  Alternatively, it may be an ID referring to
any entry, also in a different file.  In this case, the first
table in that entry will be referenced.
FORM is a field or range descriptor like \"@2$3\" or \"B3\" or
\"@I$2..@II$2\".  All the references must be absolute, not relative.

The return value is either a single string for a single field, or a
list of the fields in the rectangle."
  (save-match-data
    (let ((case-fold-search t) (id-loc nil)
	  ;; Protect a bunch of variables from being overwritten by
	  ;; the context of the remote table.
 	  org-table-column-names (org-table-column-name-regexp org-table-column-name-regexp)
	  ;; org-table-column-names org-table-column-name-regexp
	  org-table-local-parameters org-table-named-field-locations
	  org-table-current-line-types
	  org-table-current-begin-pos org-table-dlines
	  org-table-current-ncol
	  org-table-hlines
	  org-table-last-column-widths
	  org-table-last-alignment
	  buffer loc)
      (setq form (org-table-convert-refs-to-rc form))
      (org-with-wide-buffer
       (goto-char (point-min))
       (if (re-search-forward
	    (concat "^[ \t]*#\\+\\(tbl\\)?name:[ \t]*"
		    (regexp-quote name-or-id) "[ \t]*$")
	    nil t)
	   (setq buffer (current-buffer) loc (match-beginning 0))
	 (setq id-loc (org-id-find name-or-id 'marker))
	 (unless (and id-loc (markerp id-loc))
	   (user-error "Can't find remote table \"%s\"" name-or-id))
	 (setq buffer (marker-buffer id-loc)
	       loc (marker-position id-loc))
	 (move-marker id-loc nil))
       (with-current-buffer buffer
	 (org-with-wide-buffer
	  (goto-char loc)
	  (forward-char 1)
	  (unless (and (re-search-forward "^\\(\\*+ \\)\\|^[ \t]*|" nil t)
		       (not (match-beginning 1)))
	    (user-error "Cannot find a table at NAME or ID %s" name-or-id))
	  (org-table-analyze)
	  (setq form (org-table-formula-substitute-names
		      (org-table-formula-handle-first/last-rc form)))
	  (if (and (string-match org-table-range-regexp form)
		   (> (length (match-string 0 form)) 1))
	      (org-table-get-range
	       (match-string 0 form) org-table-current-begin-pos 1)
	    form)))))))
  )

(use-package paredit
    :config
  (define-key paredit-mode-map (kbd "M-q") 'fill-paragraph)
  (define-key paredit-mode-map (kbd "M-s") nil)
  (define-key paredit-mode-map (kbd "<delete>") 'delete-forward-char)

  (add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1))))

(use-package server
    :config
  (bind-key "C-x C-x"       'server-edit))

(use-package paren-face
    :config
  (global-paren-face-mode))

(use-package simple
    :config
  (bind-key "C-x t"         'delete-trailing-whitespace)
  (bind-key "C-<tab>"       'other-window)

  (put 'downcase-region 'disabled nil)
  (put 'upcase-region 'disabled nil)
  (fset 'yes-or-no-p 'y-or-n-p)
  (prefer-coding-system 'utf-8))

(use-package solarized-dark-theme
    :config
  (load-library "solarized-dark-theme")
  (set-mouse-color "white"))

(use-package time-stamp
    :config
  (bind-key "<f10>"         (lambda (arg)
			      (interactive "P")
			      (insert (time-stamp-string (concat "%:b %:d, %:y" (when arg ", %02H:%02M")))))))

(use-package vc
    :config
  (setq vc-follow-symlinks
        nil))

(use-package which-key
    :config
  (which-key-mode +1))

(use-package windmove
    :config
  (windmove-default-keybindings))

(use-package winner
    :config
  (bind-key "C-c C-<left>"  'winner-undo)
  (bind-key "C-c C-<right>" 'winner-redo))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(debug-ignored-errors
   '("^Minibuffer is inactive" "^Invalid face:? " "from selected window$" "^Completion needs an inferior Python process running." "^Can't shift all lines enough" search-failed beginning-of-line beginning-of-buffer end-of-line end-of-buffer end-of-file buffer-read-only file-supersession user-error "Nothing is selected"))
 '(display-time-mode t)
 '(file-cache-filter-regexps
   '("~$" "\\.o$" "\\.exe$" "\\.a$" "\\.elc$" ",v$" "\\.output$" "\\.$" "#$" "\\.class$" "\\.d$"))
 '(fill-column 82)
 '(find-file-visit-truename t)
 '(frame-background-mode nil)
 '(global-font-lock-mode t nil (font-lock))
 '(indent-tabs-mode nil)
 '(inhibit-startup-echo-area-meassage t)
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(safe-local-variable-values
   '((dante-repl-command-line "cabal" "v2-repl" "-O0" "-j" "common")))
 '(savehist-mode t nil (savehist))
 '(scroll-bar-mode nil)
 '(server-raise-frame nil)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(split-width-threshold 140)
 '(tool-bar-mode nil nil (tool-bar))
 '(tooltip-hide-delay 600)
 '(undo-limit 1048576)
 '(undo-outer-limit 120000000)
 '(warning-suppress-types '((\(undo\ discard-info\))))
 '(winner-mode t nil (winner))
 '(x-gtk-whole-detached-tool-bar t))

;;
;; Author: Johan "rejeep" Andersson
;; Source: http://tuxicity.se/emacs/elisp/2010/03/26/rename-file-and-buffer-in-emacs.html
;;
(defun rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))
(bind-key "C-c m"      'rename-this-buffer-and-file)

;;
;; Extra keybindings
;;
; A-la vim's 'J' command:
(bind-key "C-<up>"        'join-line)

; Scrolling
(defun scroll:helper   (x) (next-line x) (scroll-up x))
(defun scroll:lineup   () (interactive) (scroll:helper -1))
(defun scroll:linedown () (interactive) (scroll:helper 1))
(defun scroll:pageup   () (interactive) (scroll:helper (- (/ (window-height (get-buffer-window)) 2))))
(defun scroll:pagedown () (interactive) (scroll:helper (/ (window-height (get-buffer-window)) 2)))
(bind-key "C-S-<up>"      'scroll:lineup)
(bind-key "C-S-<down>"    'scroll:linedown)
(bind-key "C-S-<mouse-4>" 'scroll:lineup)
(bind-key "C-S-<mouse-5>" 'scroll:linedown)
(bind-key "C-S-<prior>"   'scroll:pageup)
(bind-key "C-S-<next>"    'scroll:pagedown)


;;;
;;; Global init
;;;
(when (file-exists-p command-line-default-directory)
  (cd command-line-default-directory))

(or (server-running-p)
    (server-start))

(put 'erase-buffer 'disabled nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :background "#002b36" :foreground "#839496" :weight normal :height 140 :width normal))))
 '(haskell-debug-warning-face ((t (:inherit 'compilation-warning))))
 '(haskell-interactive-face-compile-warning ((t (:inherit nil :foreground "#855900"))))
 '(helm-candidate-number ((t (:background "#073642" :foreground "#6c71c4"))))
 '(helm-selection ((t (:background "#073642" :underline "#268bd2"))))
 '(magit-branch ((t (:foreground "#cb4b16" :weight bold :height 0.75))))
 '(magit-cherry-equivalent ((t (:foreground "#d33682" :height 0.75))))
 '(magit-cherry-unmatched ((t (:foreground "#2aa198" :height 0.75))))
 '(magit-diff-add ((t (:inherit diff-added :height 0.75))))
 '(magit-diff-del ((t (:inherit diff-removed :height 0.75))))
 '(magit-diff-file-header ((t (:inherit diff-file-header :height 0.75))))
 '(magit-diff-hunk-header ((t (:inherit diff-hunk-header :height 0.75))))
 '(magit-diff-none ((t (:inherit diff-context :height 0.75))))
 '(magit-item-mark ((t (:inherit highlight :height 0.75))))
 '(magit-key-mode-args-face ((t (:inherit widget-field :height 0.75))))
 '(magit-key-mode-button-face ((t (:inherit font-lock-builtin-face :height 0.75))))
 '(magit-key-mode-header-face ((t (:inherit font-lock-keyword-face :height 0.75))))
 '(magit-key-mode-switch-face ((t (:inherit font-lock-warning-face :height 0.75))))
 '(magit-log-author ((t (:foreground "#2aa198" :height 0.75))))
 '(magit-log-date ((t (:height 0.75))))
 '(magit-log-graph ((t (:foreground "#586e75" :height 0.75))))
 '(magit-log-head-label-default ((t (:background "#073642" :box 1 :height 0.75))))
 '(magit-log-head-label-head ((t (:background "Grey20" :foreground "White" :box 1 :height 0.75))))
 '(magit-log-head-label-local ((t (:background "#00629D" :foreground "#69B7F0" :box 1 :height 0.75))))
 '(magit-log-head-label-patches ((t (:background "#990A1B" :foreground "#FF6E64" :box 1 :height 0.75))))
 '(magit-log-head-label-remote ((t (:background "#546E00" :foreground "#B4C342" :box 1 :height 0.75))))
 '(magit-log-head-label-tags ((t (:background "#7B6000" :foreground "#DEB542" :box 1 :height 0.75))))
 '(magit-log-head-label-wip ((t (:background "Grey07" :foreground "LightSkyBlue4" :box 1 :height 0.75))))
 '(magit-log-message ((t (:height 0.75))))
 '(magit-log-sha1 ((t (:foreground "#b58900" :height 1.0))))
 '(magit-tag ((t (:background "LemonChiffon1" :foreground "goldenrod4" :height 0.75))))
 '(variable-pitch ((t (:family "Aurulent Sans")))))

(defun try-load-native-emacs-init-files (&rest init-files)
  (let* ((home           (getenv "HOME"))
         (init-filepaths (mapcar (lambda (x) (concat home "/" x)) init-files))
         (avails         (remove-if-not 'file-exists-p init-filepaths)))
    (cond ((not (null avails))
           (message "Found native init file, loading: %s" (first avails))
           (load (first avails)))
          (t
           (message "No native init files found.")))))

(other-window 1)

(setq
 initial-scratch-message
 ";;;
;;;  em: a somewhat minimal, somewhat practical, somewhat sensible Emacs bundle.
;;;
;;   Quick summary of non-default keybindings:
;;
;; 0. Window navigation & management:
;;
;;    - S-<arrows>          Directional navigation (windmove-left/right/up/down)
;;    - C-Tab               Cycle (other-window)
;;    - C-c C-<left/right>  undo/redo _any_ window layout changes (winner-undo/redo)
;;
;; 1. Buffer navigation:
;;
;;    - M-SPC               Quick list of same-type buffers (bs-show)
;;    - S-M-SPC             Full list of buffers (ibuffer)
;;
;; 2. File/repo:
;;
;;    - `                   Quick navigate in repo files (helm-ls-git-ls)
;;    - <menu>              Everything git (magit-status)
;;    - C-c m               Rename current file and buffer (rename-this-buffer-and-file)
;;    - C-<pgup>/<pgdown>   Left sidebar: move to prev/next (neotree-tab-move)
;;
;; 3. Search (incremental, via Helm):
;;
;;    - M-s                 Grep in root of current git repo (helm-grepint-grep-root)
;;    - C-<super>-s         Hoogle inside the current Nix shell (helm-hoogle-at-point)
;;    - <f1>                Interactive Emacs command/function/variable 'apropos'.
;;    - C-x C-z             Recall results of ANY last Helm search (helm-resume)
;;
;; 4. Haskell:
;;
;;    - <f4>                Set a Cabal lib target for Dante.
;;    - open any .hs file   Dante is started, but will fail, unless you set
;;                            a proper component for it (dante-set-lib/exe) _before_.
;;    - <f5>                Restart Dante.
;;
;; 5. In Haskell buffers:
;;
;;    - M-p/M-n             Navigate between error messages.
;;
;; 6. Random stuff:
;;
;;    - <f10>               Insert current date.
;;    - C-up                Join current line to the previous one.
;;    - C-x a r             Align by regexp.
;;
")

(message " --- End of em-bundled init.el ---")

(try-load-native-emacs-init-files
 "init.el"
 ".emacs")
