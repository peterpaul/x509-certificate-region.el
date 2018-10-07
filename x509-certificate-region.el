;;; x509-certificate-region.el --- Functions for viewing the region as X509 certificate
;;; -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Peterpaul Taekele Klein Haneveld

;; Author: Peterpaul Taekele Klein Haneveld <pp.kleinhaneveld@gmail.com>
;; Version: 0.0.1
;; Keywords: openssl tools
;; Package-Requires: (x509-mode)

;; This file is not part of GNU Emacs.

;; MIT License
;;
;; Copyright (C) 2018 Peterpaul Taekele Klein Haneveld
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to
;; deal in the Software without restriction, including without limitation the
;; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;; sell copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;; IN THE SOFTWARE.

;;; Commentary:
;; x509-view-region-as-x509-certificate
;; x509-view-xml-element-as-x509-certificate

;;; Code:

(require 'x509-mode)

(defun x509--replace-all (search-regexp replacement)
  "Replace all occurrences of SEARCH-REGEXP with REPLACEMENT in current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward search-regexp nil t)
      (replace-match replacement nil nil))))

(defun x509--prepare-certificate-buffer ()
  "Remove all leading and trailing spaces per line and delete all empty lines from current buffer."
  (x509--replace-all  "^[[:blank:]]+" "")
  (x509--replace-all  "[[:blank:]]+$" "")
  (x509--replace-all  "\n+" "\n"))

(defun x509-view-region-as-x509-certificate (beg end)
  "Try to view the region marked by BEG and END as x509 certificate."
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

(defun x509-view-paragraph-as-x509-certificate ()
  "Try to view the current paragraph as x509 certificate."
  (interactive)
    (let ((beg 0)
          (end 0))
      (save-mark-and-excursion
        (mark-paragraph)
        (setq beg (region-beginning)
              end (region-end)))
    (x509-view-region-as-x509-certificate beg end)))

(defun x509-view-xml-element-as-x509-certificate (pos)
  "Try to view the xml element at POS as x509 certificate."
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

(provide 'x509-certificate-region)

;;; x509-certificate-region.el ends here
