;; This is my "poor mans denote silo".
;;
;; I found myself with a couple different "silos" of data I wanted
;; to manage in denote, but my quick stab at using denote silo
;; https://protesilaos.com/emacs/denote-silo revelaed that you
;; had to use seperate commands (denote-silo-cd, denote-silo-dired, etc) for
;; data in silos and not all commands were supported directy, e.g. denote-grep.
;; This seemed to require a shift in the mental model, and for one
;; to be constantly aware what data was in the silo and, hence,
;; what (different) command set applied.

;; Instead, I just wrote this this "poor mans" denote-silo
;; which simply between two or more independant denote directories,
;; updates the mode line so you know which silo is active and
;; remembers the last active silo across restarts.
;;
;; I'm sure I'm missing something basic, but "this works for me"
;;
;; George Jones, 2026-03-11, gmj AT pobox DOT com

; Silos of data I want to keep separate
(defvar gmj/denote-directories
  '(("main" . "~/notes/")
    ("money" . "~/money/")
    ("geneaology" . "~/private/family/geneaology/")))

; keep track of last directory
(defvar gmj/denote-last-directory-file
  (locate-user-emacs-file "gmj-denote-last-directory"))

(defun gmj/denote-switch-directory (&optional name)
  "Switch denote directory to NAME.
When called interactively, prompt for selection.
Saves the choice for future sessions."
  (interactive
   (list (completing-read "Denote directory: " gmj/denote-directories)))
  (let ((dir (alist-get name gmj/denote-directories nil nil #'string=)))
    (unless dir
      (error "Unknown denote directory: %s" name))
    (setq denote-directory dir)
    (setq denote-keyword-history nil)
    (with-temp-file gmj/denote-last-directory-file
      (insert name))
    (message "Denote directory: %s" dir)))

(defun gmj/denote-restore-last-directory ()
  "Restore the last used denote directory."
  (when (file-exists-p gmj/denote-last-directory-file)
    (let ((name (with-temp-buffer
                  (insert-file-contents gmj/denote-last-directory-file)
                  (string-trim (buffer-string)))))
      (when (alist-get name gmj/denote-directories nil nil #'string=)
        (gmj/denote-switch-directory name)))))

;; Call on startup (put after denote is loaded)
; (gmj/denote-restore-last-directory)

;; List denote "silo" on modeline
(defun my/denote-modeline-indicator ()
  (when (bound-and-true-p denote-directory)
    (concat " [" (file-name-nondirectory
                  (directory-file-name denote-directory)) "]")))

;; Add the denote "silo" to the modeline
(add-to-list 'mode-line-misc-info
             '(:eval (my/denote-modeline-indicator)))
