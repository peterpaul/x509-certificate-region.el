;;; -*- lexical-binding: t; -*-

(require 'x509-mode)

(defun x509--replace-all (search-regexp replacement)
  "Replace all occurrences of SEARCH-REGEXP with REPLACEMENT in current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward search-regexp nil t)
      (replace-match replacement nil nil))))

(defun x509--prepare-certificate-buffer ()
  "Removes all leading and trailing spaces per line and removes all empty lines from current buffer."
  (x509--replace-all  "^[[:blank:]]+" "")
  (x509--replace-all  "[[:blank:]]+$" "")
  (x509--replace-all  "\n+" "\n"))

(defun x509-view-region-as-x509-certificate (beg end)
  "Try to view the region as x509 certificate"
  (interactive
   (list (region-beginning) (region-end)))
  (save-excursion
    (let ((cert-buffer (get-buffer-create
			(format "*certificate from '%s'*" (buffer-name)))))
      (copy-to-buffer cert-buffer beg end)
      (with-current-buffer cert-buffer
	(barf-if-buffer-read-only)
	(goto-char (point-min))
	(insert "-----BEGIN CERTIFICATE-----\n")
	(goto-char (point-max))
	(insert "\n-----END CERTIFICATE-----\n")
	(x509--prepare-certificate-buffer)
	(deactivate-mark)
	(x509-viewcert (format "x509 -sha256 -fingerprint -text -noout -inform %s"
			       (x509--buffer-encoding))))
      (kill-buffer cert-buffer)
      )))

(defun x509-view-xml-element-as-x509-certificate (pos)
  "Try to view the xml element under the point as x509 certificate"
  (interactive
   (list (point)))
  (let ((beg (or (save-excursion
		  (when (search-backward ">" nil t)
		    (forward-char 1)
		    (point)))
		(point-min)))
	(end (or (save-excursion
		  (when (search-forward "<" nil t)
		    (backward-char 1)
		    (point)))
		(point-max))))
    (x509-view-region-as-x509-certificate beg end)))

(provide 'x509-certificate)
