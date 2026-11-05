;;; -*- lexical-binding: t; -*-

(use-package denote-journal
  :ensure t
  ;; Bind those to some key for your convenience.
  :commands ( denote-journal-new-entry
              denote-journal-new-or-existing-entry
              denote-journal-link-or-create-entry )
  :hook (calendar-mode . denote-journal-calendar-mode)
  :config
  
  ;; Use the "journal" subdirectory of the `denote-directory'.  Set this
  ;; to nil to use the `denote-directory' instead.
  ;;
  ;; Check if a "secret" directory exists in denote-directory;
  ;; if so, journal goes in denote-directory/secret/journal
  ;; 
  ;; else if a "private" directory exists in denote-directory;
  ;; if so, journal goes in denote-directory/private/journal
  ;; 
  ;; else 
  ;; journal goes in denote-directory/journal


  (let ((base (cond
             ((file-directory-p (expand-file-name "secret" denote-directory))
              (expand-file-name "secret" denote-directory))
             ((file-directory-p (expand-file-name "private" denote-directory))
              (expand-file-name "private" denote-directory))
             (t denote-directory))))
  (setq denote-journal-directory
        (expand-file-name "journal" base)))
  
  ;; Default keyword for new journal entries. It can also be a list of
  ;; strings.
  (setq denote-journal-keyword "journal")
  ;; Read the doc string of `denote-journal-title-format'.
  (setq denote-journal-title-format 'day-date-month-year))

(with-eval-after-load 'org-capture
       (add-to-list 'org-capture-templates
                    '("N" "Denote Journal Entry id" entry
                      (file denote-journal-path-to-new-or-existing-entry)
                      "* %U %?\n%i\n%a"
                      :kill-buffer t
                      :empty-lines 1)))

(add-to-list 'org-agenda-custom-commands
	       '("j" "Journal"
		 tags "{[Jj]ournal}"
		 ((org-agenda-files
		   (directory-files-recursively "~/notes/journal/" "\\.org$"))))
	       t)   ; t = append to end
