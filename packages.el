;;; packages.el --- better-cpp Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;; Copyright (c) 2016-2017 Marco Schlumppp
;;
;; Author: Marco Schlumpp <marco.schlumpp@gmail.com>
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; List of all packages to install and/or initialize. Built-in packages
;; which require an initialization must be listed explicitly in the list.
(setq better-cpp-packages
      '(cc-mode
        cmake-mode
        rtags
        popwin
        cpputils-cmake
        ;; Auto-completition
        company))

;; List of packages to exclude.
(setq better-cpp-excluded-packages '())

(defun better-cpp/init-cc-mode ()
  (use-package cc-mode
    :defer t
    :init
    (add-to-list 'auto-mode-alist `("\\.h$" . ,better-cpp-default-mode-for-headers))
    :config
    (evil-leader/set-key-for-mode 'c-mode
      "ga" 'projectile-find-other-file
      "gA" 'projectile-find-other-file-other-window)
    (evil-leader/set-key-for-mode 'c++-mode
      "ga" 'projectile-find-other-file
      "gA" 'projectile-find-other-file-other-window)))

(defun better-cpp/init-rtags ()
  (use-package rtags
    :defer t
    :init
    (when (configuration-layer/layer-usedp 'auto-completion)
      (require 'company-rtags)
      (push 'company-rtags company-backends-c++-mode)
      (setq rtags-completions-enabled t)
      (setq rtags-autostart-diagnostics t))

    (evil-leader/set-key-for-mode 'c++-mode
      "." 'rtags-find-symbol-at-point
      "," 'rtags-location-stack-back
      "rr" 'rtags-rename-symbol)
    (evil-leader/set-key-for-mode 'c-mode
      "." 'rtags-find-symbol-at-point
      "," 'rtags-location-stack-back
      "rr" 'rtags-rename-symbol)

    (defvar better-cpp--rtags-navigation-ms-doc-toggle 0
      "Display a short doc when nil, full doc otherwise.")

    (defun better-cpp//rtags-navigation-ms-doc ()
      (if (equal 0 better-cpp--rtags-navigation-ms-doc-toggle)
          "[?] for help"
        "
  [?] display this help [q] quit
  matches: [p] previous [n] next [,] back
  search:  [.] symbol   [r] refs [v] virtuals
  print:   [c] class hierarchy"))

    (defun better-cpp//rtags-navigation-ms-toggle-doc ()
      (interactive)
      (setq better-cpp--rtags-navigation-ms-doc-toggle
            (logxor better-cpp--rtags-navigation-ms-doc-toggle 1)))

    (spacemacs|define-micro-state rtags-navigation
      :doc (better-cpp//rtags-navigation-ms-doc)
      :persistent t
      :evil-leader-for-mode (c++-mode . "m")
      :use-minibuffer t
      :bindings
      ("?" better-cpp//rtags-navigation-ms-toggle-doc)
      ("p" rtags-previous-match)
      ("n" rtags-next-match)
      ("." rtags-find-symbol-at-point)
      ("," rtags-location-stack-back)
      ("v" rtags-find-virtuals-at-point)
      ("c" rtags-print-class-hierarchy)
      ("r" rtags-find-references-at-point)
      ("q" nil :exit t))))

(defun better-cpp/post-init-popwin ()
  (push '("*RTags*" :noselect t :position bottom :width 60) popwin:special-display-config))

(defun better-cpp/init-cpputils-cmake ()
  (use-package cpputils-cmake
    :init
    (add-hook 'c-mode-common-hook (lambda ()
                                    (when (derived-mode-p 'c-mode 'c++-mode)
                                      (cppcm-reload-all))))
    :config
    (setq cppcm-write-flycheck-makefile nil)))

(defun better-cpp/init-cmake-mode ()
  (use-package cmake-mode
    :init
    (push 'company-cmake company-backends-cmake-mode)))

(when (configuration-layer/layer-usedp 'auto-completion)
  (defun better-cpp/post-init-company ()
    (spacemacs|add-company-hook c++-mode)
    (spacemacs|add-company-hook c-mode)))
