(setq njb/org-auto-save-directory "~/Vault/njb-org-autosaves/")
(defvar njb/backup-in-progress nil "Flag to indicate if a backup operation is in progress.")

(defun njb/sanitize-for-filename (path)
  "Sanitize the entire file PATH to be safe for filenames by replacing slashes and non-alphanumeric characters."
  (replace-regexp-in-string "[^[:alnum:]-]" "_"
    (replace-regexp-in-string "/" "!" path)))

(defun njb/auto-save-org-buffers ()
  "Automatically save and check for Org-mode buffer modifications."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'org-mode) (buffer-modified-p))
        (progn (message (concat "Autosaving " (buffer-name buf)))
	       (save-buffer)
	       (message (concat "Autosaved " (buffer-name buf)))
	       )))))

(run-with-timer 0 3 'njb/auto-save-org-buffers)

(defun njb/backup-after-buffer-saved ()
  "Buffer has been saved"
  (when (derived-mode-p 'org-mode)
    (progn
      (let ((backup-file (concat njb/org-auto-save-directory
				 (njb/sanitize-for-filename (or buffer-file-name (buffer-name)))
				 "_"
				 (format-time-string "%Y-%m-%d_%H%M%S%3N.org"))))
	(copy-file (buffer-file-name) backup-file t)
	(message "Backed up Org-mode buffer to %s" backup-file))
      (message "Saved buffer: %s" (buffer-name)))))


(add-hook 'after-save-hook 'njb/backup-after-buffer-saved)

(message "Finished setting up autosaving for org-mode buffers")
