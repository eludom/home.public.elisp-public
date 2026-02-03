;; From https://mentat.za.net/blog/2026/01/27/org-mode-time-blocks/?utm_source=atom_feed

(defun stefanv/org-jump-to-today-plan ()
  "Jump to the end of the 'Plan' heading under today's date headline."
  (interactive)
  (let* ((today (regexp-quote (format-time-string (org-time-stamp-format nil t))))
         (today-re (concat "^\\*+ .*?" today)))
    (goto-char (point-min))
    (if (not (re-search-forward today-re nil t))
        (message "Heading matching %s not found." today)
      (org-reveal)
      (save-restriction
        (org-narrow-to-subtree)
        (goto-char (point-min))
        ;; Matches 'Plan' heading and optional trailing tags
        (if (re-search-forward "^\\*+ Plan\\(?:[ \t]*\\(:[[:alnum:]_@:]+:\\)\\)?[ \t]*$" nil t)
          (org-end-of-subtree)
          (widen)
          (message "No exact 'Plan' heading found under today's date."))))))

(defun stefanv/org-plan-next ()
  "Create a new day plan entry following on the current or previous lines's active timestamp."
  (interactive)
  (let* ((ts-found (save-excursion
                     (end-of-line)
                     (when (re-search-backward org-ts-regexp0 nil t)
                       (let ((ctx (org-element-context)))
                         (when (eq (org-element-type ctx) 'timestamp) ctx)))))
         (is-blank (string-blank-p (buffer-substring (line-beginning-position) (line-end-position))))
         (is-header (org-at-heading-p))
         ;; Check if the found timestamp is actually on the current line
         (on-current-line (and ts-found
                               (>= (org-element-property :begin ts-found)
                                   (line-beginning-position)))))
    (if (not ts-found)
        (user-error "No timestamp found above point")
      (cond
       ;; Already has TS OR is plain text -> new heading below
       ((or on-current-line (and (not is-blank) (not is-header)))
        (end-of-line)
        (org-insert-heading)
        (save-excursion (stefanv/insert-formatted-org-ts ts-found)))

       ;; Current line is blank -> turn into heading here
       (is-blank
        (org-insert-heading)
        (save-excursion (stefanv/insert-formatted-org-ts ts-found)))

       ;; Current line is a header (no TS) -> append TS and return cursor
       (t
        (save-excursion
          (end-of-line)
          (stefanv/insert-formatted-org-ts ts-found)))))))

(defun stefanv/insert-formatted-org-ts (ts)
  "Helper to insert formatted timestamp with exactly one preceding space."
  (just-one-space)
  (insert (format "<%s %02d:%02d>"
                  (org-format-timestamp ts "%Y-%m-%d %a")
                  (or (org-element-property :hour-end ts)
                      (org-element-property :hour-start ts) 0)
                  (or (org-element-property :minute-end ts)
                      (org-element-property :minute-start ts) 0))))

(keymap-set org-mode-map "C-c C-x p" #'stefanv/org-plan-next)


(defun stefanv/org-shift-timestamps-in-region (minutes)
  "Shift all active timestamps in the region (or current line) forward by MINUTES minutes."
  (interactive "nMinutes to shift: ")
  (let* ((region-active (use-region-p))
         (beg (if region-active (region-beginning) (line-beginning-position)))
         (end (copy-marker (if region-active (region-end) (line-end-position))))
         ;; Regex for active timestamps: matches < followed by anything until >
         (active-ts-re "<\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}.*?\\)>"))
    ;; Allow undoing everything in one step
    (atomic-change-group
      (save-excursion
        (goto-char beg)
        ;; Shift active timestamps
        (while (re-search-forward active-ts-re end t)
          (save-excursion
            (goto-char (match-beginning 0))
            (org-timestamp-change minutes 'minute)
            (when (fboundp 'org-element-cache-refresh)
              (org-element-cache-refresh (point)))))

        ;; Re-align tags for any headlines in the range
        (goto-char beg)
        (while (re-search-forward org-outline-regexp-bol end t)
          (org-align-tags))))

    ;; Refresh
    (font-lock-flush beg end)
    (set-marker end nil)
    (message "Shifted active timestamps by %s minutes." minutes)))
;; 
;; I've added the following org capture template to start.
;;
;; Also ~/org/2026.org has been added to my agenda
;; 
  ;; ("d" "Day Planner" entry (file+olp+datetree "~/org/2026.org")
  ;;  "** %u
  ;;    baz
  
  ;; - [ ] Scan [[notmuch-search:tag:unread][Notmuch search: tag:unread]] for new tasks (max 10 mins)
  ;; - [ ] Review Org Agenda for old tasks (max 10 mins)
  
  ;; *** Plan
  ;; **** 
  ;; **** Lunch + walk <%<%Y-%m-%d %a 13:00-13:45>>
  ;; **** 
  ;; **** Wrap up and review <%<%Y-%m-%d %a 16:45-17:00>>
  
  ;; *** Notes
  ;; *** End of day review
  ;;     - What went well ::
  ;;     - What could improve :: 
  ;;     - Priority for tomorrow :: 

  ;; ")
