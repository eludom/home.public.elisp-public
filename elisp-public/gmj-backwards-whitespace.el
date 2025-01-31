(defun gmj-backward-whitespace ()
  "Move point backward over whitespace, including newlines."
  (interactive)
  (skip-chars-backward " \t\n"))
