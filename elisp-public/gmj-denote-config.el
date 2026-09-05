;; George Jones' denote config  -*- lexical-binding: t; -*-
;; 2024-12-08
;;
;; From https://protesilaos.com/emacs/denote#h:f3bdac2c-4704-4a51-948c-a789a2589790

;; Remember to check the doc strings of those variables.
;; (setq denote-directory (expand-file-name "~/notes/"))
(setq denote-save-buffers nil)
;; (setq denote-known-keywords '("emacs" "philosophy" "politics" "economics"))
;; (setq denote-known-keywords '("finances" "medical" "retirement" "planning" "house" "hacking" "life" "blogging" "patc" "family" ))
(setq denote-infer-keywords t)
(setq denote-sort-keywords t)
(setq denote-file-type nil) ; Org is the default, set others here
(setq denote-prompts '(title keywords))
(setq denote-excluded-directories-regexp nil)
(setq denote-excluded-keywords-regexp nil)
(setq denote-rename-confirmations '(rewrite-front-matter modify-file-name))

;; Pick dates, where relevant, with Org's advanced interface:
(setq denote-date-prompt-use-org-read-date t)


;; Read this manual for how to specify `denote-templates'.  We do not
;; include an example here to avoid potential confusion.


(setq denote-date-format nil) ; read doc string

;; By default, we do not show the context of links.  We just display
;; file names.  This provides a more informative view.
(setq denote-backlinks-show-context t)

;; Also see `denote-backlinks-display-buffer-action' which is a bit
;; advanced.

;; If you use Markdown or plain text files (Org renders links as buttons
;; right away)
(add-hook 'text-mode-hook #'denote-fontify-links-mode-maybe)

;; We use different ways to specify a path for demo purposes.
;; (setq denote-dired-directories
;;       (list denote-directory
;;             (thread-last denote-directory (expand-file-name "attachments"))
;;             (expand-file-name "~/Documents/books")))

;; Generic (great if you rename files Denote-style in lots of places):
;; (add-hook 'dired-mode-hook #'denote-dired-mode)
;;
;; OR if only want it in `denote-dired-directories':
(add-hook 'dired-mode-hook #'denote-dired-mode-in-directories)


;; Automatically rename Denote buffers using the `denote-rename-buffer-format'.
(denote-rename-buffer-mode 1)

;; Denote DOES NOT define any key bindings.  This is for the user to
;; decide.  For example:
(let ((map global-map))
  (define-key map (kbd "C-c n n") #'denote)
  (define-key map (kbd "C-c n c") #'denote-region) ; "contents" mnemonic
  (define-key map (kbd "C-c n N") #'denote-type)
  (define-key map (kbd "C-c n d") #'denote-date)
  (define-key map (kbd "C-c n z") #'denote-signature) ; "zettelkasten" mnemonic
  (define-key map (kbd "C-c n s") #'denote-subdirectory)
  (define-key map (kbd "C-c n t") #'denote-template)
  ;; If you intend to use Denote with a variety of file types, it is
  ;; easier to bind the link-related commands to the `global-map', as
  ;; shown here.  Otherwise follow the same pattern for `org-mode-map',
  ;; `markdown-mode-map', and/or `text-mode-map'.
  (define-key map (kbd "C-c n i") #'denote-link) ; "insert" mnemonic
  (define-key map (kbd "C-c n I") #'denote-add-links)
  (define-key map (kbd "C-c n b") #'denote-backlinks)
  (define-key map (kbd "C-c n f f") #'denote-find-link)
  (define-key map (kbd "C-c n f b") #'denote-find-backlink)
  ;; Note that `denote-rename-file' can work from any context, not just
  ;; Dired bufffers.  That is why we bind it here to the `global-map'.
  (define-key map (kbd "C-c n r") #'denote-rename-file)
  (define-key map (kbd "C-c n R") #'denote-rename-file-using-front-matter))

;; Key bindings specifically for Dired.
(let ((map dired-mode-map))
  (define-key map (kbd "C-c C-d C-i") #'denote-dired-link-marked-notes)
  (define-key map (kbd "C-c C-d C-r") #'denote-dired-rename-files)
  (define-key map (kbd "C-c C-d C-k") #'denote-dired-rename-marked-files-with-keywords)
  (define-key map (kbd "C-c C-d C-R") #'denote-dired-rename-marked-files-using-front-matter))

(with-eval-after-load 'org-capture
  (setq denote-org-capture-specifiers "%l\n%i\n%?")
  (add-to-list 'org-capture-templates
               '("n" "New note (with denote.el)" plain
                 (file denote-last-path)
                 #'denote-org-capture
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t)))

;;
;; Define my denote AI query template
;; 

(defun my/ai-query-capture-file ()
  "Return a fresh Denote-style file name for an AI query note."
  (let* ((id (format-time-string "%Y%m%dT%H%M%S"))
         (title (read-string "Title: "))
         (slug (replace-regexp-in-string
                "[^a-z0-9]+" "-" (downcase title))))
    (setq my/ai-query--title title
          my/ai-query--id id)
    (expand-file-name
     (format "%s--%s__chat_planning_tech.org" id (string-trim slug "-" "-"))
     (or (bound-and-true-p denote-directory) org-directory))))

(defvar my/ai-query--title nil)
(defvar my/ai-query--id nil)

(when (assoc "A" org-capture-templates)
  (message "Overriding existing capture template \"A\""))
(setq org-capture-templates
      (assoc-delete-all "A" org-capture-templates))
(add-to-list 'org-capture-templates
 '("A" "AI query (new Denote-style file)" plain
   (file my/ai-query-capture-file)
   "#+title:      %(identity my/ai-query--title)
#+date:       %U
#+filetags:   :chat:planning:tech:
#+identifier: %(identity my/ai-query--id)

This is a chat session with %(format \"%s\" (or (bound-and-true-p gptel-model) \"unset\")).
 
* Question
%?
 
** answer

* Follow-up question

** answer
"
   :unnarrowed t
   :jump-to-captured t))
					;

;;
;; Add my new template (or replace existing)
;;

;;
;; Define an system prompt to be used with denote/AI queries
;;
;; TODO
;;  - after first question, suggest a new short, relevant #+tile: if not already relevant
;;  - Always use org mode, never markdown
;;  - Prompts below "* question", answers under "** answer" below
;;  - once answer is given, insert next "* question" and position cursor there.

;; Also check the commands `denote-link-after-creating',
;; `denote-link-or-create'.  You may want to bind them to keys as well.


;; If you want to have Denote commands available via a right click
;; context menu, use the following and then enable
;; `context-menu-mode'.
(add-hook 'context-menu-functions #'denote-context-menu)

;; My "poor-mans-denote silo" has been broken out into gmj-denote-silo.el
