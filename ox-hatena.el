;;; ox-hatena.el --- Hatena Notation Back-End for Org Export Engine

;; Copyright (C) 2013  akisute3 <akisute3@gmail.com>

;; Author: akisute3 <akisute3@gmail.com>
;; Version: 0.1
;; Package-Requires: ((org "8.0"))
;; Keywords: org export hatena

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Installation:

;; (require 'ox-hatena)

;;; Code:


;;; Dependencies

(require 'ox)


;;; Define Back-End

(org-export-define-backend 'hatena
  '((section . org-hatena-section)
    (headline . org-hatena-headline)
    (paragraph . org-hatena-paragraph)
    (plain-list . org-hatena-plain-list)
    (item . org-hatena-item)
    (quote-block . org-hatena-quote-block)
    (example-block . org-hatena-example-block)
    (fixed-width . org-hatena-fixed-width)
    (inline-src-block . org-hatena-inline-src-block)
    (src-block . org-hatena-src-block)
    (footnote-reference . org-hatena-footnote-reference)
    (link . org-hatena-link)
    (table . org-hatena-table)
    (table-cell . org-hatena-table-cell)
    (table-row . org-hatena-table-row)
    (template . org-hatena-template)
    ;;; add ;;;
    (bold . org-hatena-bold)
    (italic . org-hatena-italic)
    (underline . org-hatena-underline)
    (code . org-hatena-code)
    (verbatim . org-hatena-verbatim)
    (strike-through . org-hatena-strike-through)
    (latex-fragment . org-hatena-latex-fragment)
    (timestamp . org-hatena-timestamp)
    (center-block . org-hatena-center-block)
    (clock . (lambda (&rest args1) (debug))) ; org-ascii-clock)
    (drawer . org-hatena-drawer)
    (dynamic-block . org-hatena-dynamic-block)
    (entity . (lambda (&rest args2) (debug))) ; org-ascii-entity)
    (export-block . (lambda (&rest args3) (debug))) ; org-ascii-export-block)
    (export-snippet . (lambda (&rest args4) (debug))) ; org-ascii-export-snippet)
    (horizontal-rule . org-hatena-horizontal-rule)
    (inlinetask . (lambda (&rest args5) (debug))) ; org-ascii-inlinetask)
    (latex-environment . (lambda (&rest args7) (debug))) ; org-ascii-latex-environment)
    (planning . (lambda (&rest args8) (debug))) ; org-ascii-planning)
    (quote-section . (lambda (&rest args9) (debug))) ;org-ascii-quote-section)
    (radio-target . org-hatena-radio-target)
    (special-block . org-hatena-special-block)
    (statistics-cookie . (lambda (&rest args10) (debug))) ; org-ascii-statistics-cookie)
    (subscript . org-hatena-subscript)
    (superscript . org-hatena-superscript)
    (verse-block . org-hatena-verse-block)
    ;;;;;;;;;;
    )
  ;;; add ;;;
  :export-block "hatena"
  :options-alist
  '((:title "TITLE" nil nil space)
    (:filetags "FILETAGS" nil ":1:2:3:" nil)
    (:date "DATE" nil nil t))
  ;;;;;;;;;;;

  :menu-entry
  '(?b "Export to Hatena Notation"
       ((?B "As Hatena Notation buffer" org-hatena-export-as-hatena)
	(?b "As Hatena Notation file" org-hatena-export-to-hatena)
	(?o "As Hatena Notation file and open" org-hatena-export-to-hatena-and-open))))


;;; Internal Variables

(defvar org-hatena-extension "hat")

(defvar org-hatena-output-mode 'diary)

;;; Functions for Back-End

(defun org-hatena-section (section contents info)
  contents)

(defun org-hatena-headline (headline contents info)
  (let* ((raw-level (org-export-get-relative-level headline info))
	 (level (cond ((eq org-hatena-output-mode 'blog)
		       raw-level)
		      ((eq org-hatena-output-mode 'diary)
		       (1+ raw-level))))
	 (section-fmt (concat (make-string level ?*) " %s\n%s"))
	 (text (org-export-data (org-element-property :title headline) info))
	 (pre-blanks (make-string (org-element-property :pre-blank headline) ?\n)))
    (format section-fmt text (concat pre-blanks contents))))

(defun org-hatena-paragraph (paragraph contents info)
  contents)

(defun org-hatena-plain-list (list contents info)
  contents)

(defun org-hatena-item (item contents info)
  (let* ((type (org-element-property :type (org-export-get-parent item)))
	 ;; (struct (org-element-property :structure (org-export-get-parent item)))
	 ;; add from ox-html
	 (tag (let ((tag (org-element-property :tag item)))
		(and tag (org-export-data tag info))))
	 ;;
	 (bullet
	  (cond ((eq type 'unordered) "-")
		((eq type 'ordered) "+")
		;; descriptiveの時 ([-+].* :: .* )
		;; はてな記法では :～～:～～
		((eq type 'descriptive) (concat ":" tag ":"))))
	 text)
    (replace-regexp-in-string "^\\([^-+]\\)" (concat bullet "\\1")
			      (replace-regexp-in-string "^\\([-+]\\)" "\\1\\1" contents))))

(defun org-hatena-quote-block (quote-block contents info)
  (format ">>\n%s<<" contents))

(defun org-hatena-example-block (example-block contents info)
  (when (org-string-nw-p (org-element-property :value example-block))
    (format ">||\n%s||<"
	    (org-remove-indentation
	     (org-export-format-code-default example-block info)))))

(defun org-hatena-fixed-width (fixed-width contents info)
  (format ">||\n%s||<"
	  (org-remove-indentation
	   (org-element-property :value fixed-width))))

(defun org-hatena-src-block (src-block contents info)
  (when (org-string-nw-p (org-element-property :value src-block))
    (format ">|%s|\n%s||<"
	    (org-element-property :language src-block)
	    (org-export-format-code-default src-block info))))

(defun org-hatena-footnote-reference (footnote-reference contents info)
  (let ((def (org-export-get-footnote-definition footnote-reference info)))
    (format "((%s))"
	    (org-trim (org-export-data def info)))))

(defun org-hatena-link (link desc info)
  (let* ((type (org-element-property :type link))
	 (raw-path (org-element-property :path link))
	 (path (cond
		((member type '("http" "https" "ftp" "mailto"))
		 (concat type ":" raw-path))
		(t raw-path)))
	 (option (and desc (= (aref desc 0) ?:) desc)))
    (cond (option
	   (format "[%s%s]" path option))
	  (desc
	   (format "[%s:title=%s]" path desc))
	  (t
	   path))))

(defun org-hatena-table (table contents info)
  contents)

(defun org-hatena-table-row (table-row contents info)
  (when (eq (org-element-property :type table-row) 'standard)
    (concat
     (if (org-export-table-row-starts-header-p table-row info)
	 (replace-regexp-in-string "|" "|*" contents)
       contents)
     "|\n")))

(defun org-hatena-table-cell (table-cell contents info)
  (concat "|" contents))

(defun org-hatena-template (contents info)
  (let ((title (org-export-data (plist-get info :title) info))
	(tags (plist-get info :filetags)))
    (cond ((eq org-hatena-output-mode 'blog)
	   (format "[%s] %s\n----------\n\n%s"
		   (mapconcat 'identity tags "][")
		   title
		   contents))
	  ((eq org-hatena-output-mode 'diary)
	   (if tags
	       (format "*[%s] %s\n\n%s"
		       (mapconcat 'identity tags "][")
		       title
		       contents)
	     (format "* %s\n\n%s" title contents))))))

;;; End-user functions

(defun org-hatena-export-as-hatena (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (if async
      (org-export-async-start
	  (lambda (output)
	    (with-current-buffer (get-buffer-create "*Org HATENA Export*")
	      (erase-buffer)
	      (insert output)
	      (goto-char (point-min))
	      (set-auto-mode t)
	      (org-export-add-to-stack (current-buffer) 'hatena)))
	`(org-export-as 'hatena ,subtreep ,visible-only ,body-only ',ext-plist))
    (let ((outbuf (org-export-to-buffer
		   'hatena "*Org HATENA Export*" subtreep visible-only body-only ext-plist)))
      (with-current-buffer outbuf (set-auto-mode t))
      (when org-export-show-temporary-export-buffer
	(switch-to-buffer-other-window outbuf)))))

(defun org-hatena-export-to-hatena (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let* ((extension (concat "." org-hatena-extension))
	 (outfile (org-export-output-file-name extension subtreep)) ;original
;         (outfile (org-export-output-file-name extension subtreep org-hatena-output-directory))
	 )
    (if async
	(org-export-async-start
	    (lambda (f) (org-export-add-to-stack f 'hatena))
	  `(expand-file-name
	    (org-export-to-file
	     'hatena ,outfile ,subtreep ,visible-only ,body-only ',ext-plist)))
      (org-export-to-file
       'hatena outfile subtreep visible-only body-only ext-plist))))

(defun org-hatena-export-to-hatena-and-open (async subtreep visible-only body-only)
  (if async (org-hatena-export-to-hatena t subtreep visible-only body-only)
    (org-open-file (org-hatena-export-to-hatena nil subtreep visible-only body-only))))

;;; add ;;;
;;;;; Bold
(defun org-hatena-bold (bold contents info)
  (format "<b>%s</b>" contents))
;;;;; Italic
(defun org-hatena-italic (italic contents info)
  (format "<i>%s</i>" contents))
;;;;; Underline
(defun org-hatena-underline (underline contents info)
  (format "<span style=\"text-decoration: underline;\">%s</span>" contents))
;;;;; Code
(defun org-hatena-code (code contents info)
  "Return a CODE object from Org to Hatena.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (format "<code>%s</code>" (org-element-property :value code)))
;;;;; verbatim
(defun org-hatena-verbatim (verbatim contents info)
  "Return a VERBATIM object from Org to Hatena.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (format "<code>%s</code>"
	  (org-element-property :value verbatim)))

;;;;; Strike-through
(defun org-hatena-strike-through (strike-through contents info)
  (format "<del>%s</del>" contents))

; inport form ox-ascii
(defun org-hatena-latex-fragment (latex-fragment contents info)
  "Transcode a LATEX-FRAGMENT object from Org to ASCII.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (when (plist-get info :with-latex)
    (org-element-property :value latex-fragment)))

(defun org-hatena-plain-text (text info)
  "Transcode a TEXT string from Org to Hatena.
TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  (let ((output text))
    ;; do nothing.
    ;; Return value.
    output))

(defun org-hatena-timestamp (timestamp contents info)
  "Transcode a TIMESTAMP object from Org to Hatena.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (org-hatena-plain-text (org-timestamp-translate timestamp) info))

;;;; Center Block

(defun org-hatena-center-block (center-block contents info)
  "Transcode a CENTER-BLOCK element from Org to HATENA.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  contents)

;;;; Drawer

(defun org-hatena-drawer (drawer contents info)
  "Transcode a DRAWER element from Org to HATENA.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  contents)


;;;; Dynamic Block

(defun org-hatena-dynamic-block (dynamic-block contents info)
  "Transcode a DYNAMIC-BLOCK element from Org to HATENA.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  contents)

;;;; Horizontal Rule

(defun org-hatena-horizontal-rule (horizontal-rule contents info)
  "Transcode an HORIZONTAL-RULE  object from Org to HATENA.
CONTENTS is nil.  INFO is a plist holding contextual information."
  "<hr />")

;;;; Radio Target

(defun org-hatena-radio-target (radio-target contents info)
  "Transcode a RADIO-TARGET object from Org to HATENA.
CONTENTS is the contents of the target.  INFO is a plist holding
contextual information."
  (debug)
  contents)

;;;; Special Block

(defun org-hatena-special-block (special-block contents info)
  "Transcode a SPECIAL-BLOCK element from Org to HATENA.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  contents)

;;;; Subscript

(defun org-hatena-subscript (subscript contents info)
  "Transcode a SUBSCRIPT object from Org to HATENA.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (if (org-element-property :use-brackets-p subscript)
      (format "<sub>%s</sub>" contents)
    (format "_%s" contents)))

;;;; Superscript

(defun org-hatena-superscript (superscript contents info)
  "Transcode a SUPERSCRIPT object from Org to HATENA.
CONTENTS is the contents of the object.  INFO is a plist holding
contextual information."
  (if (org-element-property :use-brackets-p superscript)
      (format "<sup>%s</sup>" contents)
    (format "^%s" contents)))

;;;; Verse Block

(defun org-hatena-verse-block (verse-block contents info)
  "Transcode a VERSE-BLOCK element from Org to HATENA.
CONTENTS is verse block contents.  INFO is a plist holding
contextual information."
  (format ">|\n%s|<" contents))
;;;;;;;;;;;


(provide 'ox-hatena)
;;; ox-hatena.el ends here
