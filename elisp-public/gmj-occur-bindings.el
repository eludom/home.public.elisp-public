;; -*- lexical-binding: t; -*-

(defun gmj--generate-mode-and-bindings-buffer ()
  "Combine output of `describe-mode' and `describe-bindings'."
  (let ((combined-buf "*Help-Mode-And-Bindings*")
        mode-text bindings-text)
    ;; Temporarily run help commands and capture buffer text
    (save-window-excursion
      (describe-mode)
      (setq mode-text (with-current-buffer "*Help*" (buffer-string)))
      (describe-bindings)
      (setq bindings-text (with-current-buffer "*Help*" (buffer-string))))
    
    ;; Populate combined buffer
    (with-current-buffer (get-buffer-create combined-buf)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert "================ DESCRIBE MODE ================\n\n")
        (insert mode-text)
        (insert "\n\n================ DESCRIBE BINDINGS ================\n\n")
        (insert bindings-text)
        (help-mode)
        (goto-char (point-min))))
    combined-buf))

(defun gmj-occur-bindings (arg)
  "List current mode info and keybindings in *Help-Mode-And-Bindings*.

With no prefix argument, display the combined buffer.

With `C-u` (ARG = 4), prompt for a string and run `occur` on the combined buffer."
  (interactive "p")
  (let ((buf (gmj--generate-mode-and-bindings-buffer)))
    (cond
     ((= arg 1)
      (switch-to-buffer-other-window buf))
     ((= arg 4)
      (let ((occur-string (read-string "Search mode & bindings for: ")))
        (switch-to-buffer-other-window buf)
        (unless (string-empty-p occur-string)
          (occur occur-string)))))))

(global-set-key (kbd "C-h b") 'gmj-occur-bindings)
