(defun my/update-last-saved ()
  "Insert or update a #+last_saved: timestamp at top of the file."
  (when (and buffer-file-name
             (string-match "\\.org\\'" buffer-file-name))
    (save-excursion
      (goto-char (point-min))
      (let ((ts (format-time-string "%Y-%m-%d %H:%M")))
        (cond
         ;; If already present, replace it
         ((re-search-forward "^#\\+last_saved:.*" 1000 t)
	  ;; Allow up to 10 lines with an average of 100 chars
          (replace-match (concat "#+last_saved: " ts)))
         ;; Otherwise insert at top
         (t
          (goto-char (point-min))
	    ;; Skip over lines that start with #,'
	    (while (and (not (eobp))
			(looking-at "^#"))
	      (forward-line 1))
            (insert "#+last_saved: " ts "\n\n")))))))

(add-hook 'before-save-hook #'my/update-last-saved)

