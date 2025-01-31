(global-set-key (kbd "C-h b") 'gmjOccurBindings)

(defun gmjOccurBindings (arg)
  "This is a function to list current keybindings and do an occur match


With no arguments, it is a pass-through to describe-bindings

When preceded with 1 `universal-argument' (^u^u),
prompt for OCCUR string and do an occur search for that string.
"
  (interactive "p")
  (progn

    ; if arg is 1, just call describe-bindings
    (if (= arg 1)
      (describe-bindings)

      ; if arg = 4, get string and do occur
      (if (= arg 4)
        (progn
          (setq occurString (read-string (format "search bindnigs for: ") nil nil ""))
          (describe-bindings)
          (switch-to-buffer-other-window "*Help*")
          (if (not (equal occurString ""))
            (occur occurString))
        )
      )
    )
  )
)
