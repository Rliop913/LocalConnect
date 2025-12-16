;;;; peer2peer.lisp

(in-package #:clisp-back)

(hunchentoot:define-easy-handler (hello :uri "/ping") () 
    "pong")


(hunchentoot:define-easy-handler (recv-peer-list :uri "/recv-peer-list") (ipcsv)
    (dolist (p (parse-csv ipcsv))
        (pushnew p *peers* :test #'string=))
    "OK")

(hunchentoot:define-easy-handler (receive_txt :uri "/recv_txt") (txt)
        (pushnew txt *pure_texts* :test #'string=)
    "OK")

(hunchentoot:define-easy-handler (recv-file-list :uri "/recv-file-list") (filescsv)
    (dolist (p (parse-csv-b64 filescsv))
        (pushnew p *globfiles* :test #'equal))
    "OK")

(defun broadcast-peer-list ()
    (loop for target in *peers* do
        (dex:post (makeuri target "recv-peer-list")
        :content `(("ipcsv" . ,(encode-csv *peers*))))))

(defun broadcast-file-list ()
    (loop for target in *peers* do
        (dex:post (makeuri target "recv-file-list")
        :content `(("filescsv" . ,(encode-csv-b64 *globfiles*))))))

