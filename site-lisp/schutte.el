(defun schutte/homed (&optional path)
  "return an expanded path to a file/directory in the home directory"
  (expand-file-name (or path "") "~/"))

(defun schutte/emacsd (&optional path)
  "return a path to a file in emacs.d"
  (expand-file-name (or path "") user-emacs-directory))

(defun schutte/emacsd-etc (&optional path)
  (schutte/emacsd (concat "etc/" path)))

(defun schutte/emacsd-var (&optional path)
  (schutte/emacsd (concat "var/" path)))

(provide 'schutte)
