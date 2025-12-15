;;;; utils.lisp

(in-package #:clisp-back)


(defun txt2qr (text)
    (flexi-streams:with-output-to-sequence (s :element-type '(unsigned-byte 8))
    (cl-qrencode:encode-png-stream
        text
        s
        :margin 1
    ))
)



(defparameter *port* 42312)

(defun makeuri (ip path)
    (format nil "http://~A:~A/~A" ip *port* path)
)

(defun makeuri_with_args (ip path args)
    (format nil "http://~A:~A/~A?~{~A=~A~^&~}" ip *port* path
        (mapcan (lambda (pair)
            (list (first pair) (second pair)))
            args)))

(defun encode-b64-list (rawlist)
  (let (result)
    (dolist (node rawlist (nreverse result))
      (with-standard-io-syntax
        (let* ((*print-circle* t)
               (*print-readably* t)
               (s (with-output-to-string (out) (write node :stream out)))
               (octets (flexi-streams:string-to-octets s :external-format :utf-8))
               (b64 (cl-base64:usb8-array-to-base64-string octets)))
          (pushnew b64 result :test #'string=))))))

(defun decode-b64-list (b64list)
  (let (result)
    (dolist (node b64list (nreverse result))
      (let* ((octets (cl-base64:base64-string-to-usb8-array node))
             (s (flexi-streams:octets-to-string octets :external-format :utf-8)))
        (with-standard-io-syntax
          (let ((*read-eval* nil))
            (multiple-value-bind (obj pos) (read-from-string s)
              (declare (ignore pos))
              (pushnew obj result :test #'equal))))))))


(defun encode-csv (lists)
    (cl-csv:write-csv lists))


(defparameter *peers* nil)

(defparameter *pure_texts* nil)

(defparameter *download-dir* #p"./")

(defparameter *globfiles* nil)

(defparameter *localfiles* nil)

(defun fill-file-glob (authip path)
    (pushnew (list authip path) *globfiles* :test #'equal ))

(defun fill-file-local (path)
    (pushnew path *localfiles* :test #'string= ))

(defun parse-csv (csv)
    (cl-csv:read-csv csv))

(defun parse-csv-b64 (b64csv)
    (decode-b64-list (parse-csv b64csv)))

(defun encode-csv-b64 (rawlist)
    (encode-csv (encode-b64-list rawlist)))