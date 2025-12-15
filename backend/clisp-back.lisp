;;;; clisp-back.lisp

(in-package #:clisp-back)



;;use http on develop
(defparameter *server*
    (make-instance 'hunchentoot:easy-acceptor
        :port *port*))


(hunchentoot:define-easy-handler (gen_qr :uri "/qr") (text) 
    (setf (hunchentoot:content-type*) "image/png")
    (txt2qr text))

(hunchentoot:define-easy-handler (gen-download-qr :uri "/download-qr") (ip file)
    (setf (hunchentoot:content-type*) "image/png")
    (txt2qr (makeuri_with_args ip "download" `(("file" ,file))))
)

(hunchentoot:define-easy-handler (list-texts :uri "/list-texts") ()
    (setf (hunchentoot:content-type*) "text/csv")
    (if ( = (length *pure_texts*) 0)
        "NIL"
        (encode-csv-b64 *pure_texts*)))

(hunchentoot::define-easy-handler (list-files :uri "/list-files") ()
    (setf (hunchentoot:content-type*) "text/csv")
    (if ( = (length *globfiles*) 0)
        "NIL"
        (encode-csv-b64 *globfiles*)))



(hunchentoot:start *server*)

(format t "Server Started~%")