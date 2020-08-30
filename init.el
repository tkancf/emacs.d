;; tkan's init.el.
;; I referred to this article.
;; https://emacs-jp.github.io/tips/emacs-in-2020

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

;; パッケージ管理(leaf)
(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)
    (leaf evil :ensure t)

    :config

    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここから下にいっぱい設定を書く
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

;; builtins の設定変更
(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))
  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "tkancf")
            (user-mail-address . "tkncf789@gmail.com")
            (user-login-name . "tkancf")
            (create-lockfiles . nil)
            (debug-on-error . t)
            (init-file-debug . t)
            (frame-resize-pixelwise . t)
            (enable-recursive-minibuffers . t)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (scroll-preserve-screen-position . t)
            (scroll-conservatively . 100)
            (mouse-wheel-scroll-amount . '(1 ((control) . 5)))
            (ring-bell-function . 'ignore)
            (text-quoting-style . 'straight)
            (truncate-lines . t)
            ;; (use-dialog-box . nil)
            ;; (use-file-dialog . nil)
            ;; (menu-bar-mode . t)
            ;; (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  (keyboard-translate ?\C-h ?\C-?))

;; Emacsの外でファイルが書き変わったときに自動的に読み直すマイナーモード
(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 0.3)
           (auto-revert-check-vc-info . t))
  :global-minor-mode global-auto-revert-mode)

;; Cやそれに似た構文を持つファイルに関する設定
(leaf cc-mode
  :doc "major mode for editing C and similar languages"
  :tag "builtin"
  :defvar (c-basic-offset)
  :bind (c-mode-base-map
         ("C-c c" . compile))
  :mode-hook
  (c-mode-hook . ((c-set-style "bsd")
                  (setq c-basic-offset 4)))
  (c++-mode-hook . ((c-set-style "bsd")
                    (setq c-basic-offset 4))))

;; 対応するカッコを強調表示するマイナーモード
(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

;; バックアップファイルに助けられることもあるので、 .emacs.d 以下にディレクトリを掘って、そこに保存する
(leaf files
  :doc "file input and output commands for Emacs"
  :tag "builtin"
  :custom `((auto-save-timeout . 15)
            (auto-save-interval . 60)
            (auto-save-file-name-transforms . '((".*" ,(locate-user-emacs-file "backup/") t)))
            (backup-directory-alist . '((".*" . ,(locate-user-emacs-file "backup"))
                                        (,tramp-file-name-regexp . nil)))
            (version-control . t)
            (delete-old-versions . t)))

;; font
;; 等幅になるようにRictyを設定
(leaf faces :config (set-face-attribute 'default nil :family "Ricty" :height 200))
(leaf *set-fontset-font
  :config
  (set-fontset-font t 'unicode (font-spec :name "Ricty") nil 'append)
  (set-fontset-font t '(#x1F000 . #x1FAFF) (font-spec :name "Noto Color Emoji") nil 'append))

;; theme
(leaf theme
  :config
  (load-theme 'wombat t))

;; evil config

(leaf evil
  :setq
  ((evil-want-C-u-scroll . t))
  :config
  (with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd ":") 'evil-repeat-find-char)
    (define-key evil-motion-state-map (kbd ";") 'evil-ex))
  (evil-mode 1))

(leaf leaf-convert
  :require dashboard
  :config
  (dashboard-setup-startup-hook)
  (leaf dashboard
    :ensure t
    :require t
    :config
    (dashboard-setup-startup-hook)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ここまでに色々設定を書く

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-revert-check-vc-info t)
 '(auto-revert-interval 0.3)
 '(auto-save-file-name-transforms '((".*" "~/.emacs.d/backup/" t)))
 '(auto-save-interval 60)
 '(auto-save-timeout 15)
 '(backup-directory-alist '((".*" . "~/.emacs.d/backup") ("\\`/[^/:]+:[^/:]*:")))
 '(create-lockfiles nil)
 '(debug-on-error t)
 '(delete-old-versions t)
 '(enable-recursive-minibuffers t)
 '(frame-resize-pixelwise t)
 '(history-delete-duplicates t)
 '(history-length 1000)
 '(imenu-list-position 'left t)
 '(imenu-list-size 30 t)
 '(indent-tabs-mode nil)
 '(init-file-debug t t)
 '(mouse-wheel-scroll-amount '(1 ((control) . 5)))
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa" . "https://melpa.org/packages/")
     ("org" . "https://orgmode.org/elpa/")))
 '(package-selected-packages '(blackout el-get hydra leaf-keywords leaf))
 '(ring-bell-function 'ignore)
 '(scroll-bar-mode nil)
 '(scroll-conservatively 100)
 '(scroll-preserve-screen-position t)
 '(show-paren-delay 0.1)
 '(text-quoting-style 'straight)
 '(truncate-lines t)
 '(user-full-name "tkancf")
 '(user-login-name "tkancf" t)
 '(user-mail-address "tkncf789@gmail.com")
 '(version-control t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
