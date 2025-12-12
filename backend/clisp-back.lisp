;;;; clisp-back.lisp

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




(defun convert-into-b64-list (rawlist)
    (let (result)
        (loop for node in rawlist do 
            (let* 
                ((safestr (prin1-to-string node) )
                (octets (flexi-streams:string-to-octets safestr :external-format :utf-8))
                (cvted (cl-base64:usb8-array-to-base64-string octets)))
                (pushnew cvted result :test #'string=)))
    result))



;;use http on develop
(defparameter *server*
    (make-instance 'hunchentoot:easy-acceptor
        :port *port*))

(defparameter *peers* nil)

(defparameter *pure_texts* nil)

(hunchentoot:define-easy-handler (hello :uri "/ping") () 
    "pong")

(hunchentoot:define-easy-handler (gen_qr :uri "/qr") (text) 
    (setf (hunchentoot:content-type*) "image/png")
    (txt2qr text))

(hunchentoot:define-easy-handler (receive_txt :uri "/recv_txt") (msg)
    (pushnew msg *pure_texts* :test #'string=)
    "OK")

(hunchentoot:define-easy-handler (get_texts :uri "/get_texts") ()
    (setf (hunchentoot:content-type*) "text/csv")
    (if ( = (length *pure_texts*) 0)
        "NIL"
        (format nil "~{~A~^,~}" (convert-into-b64-list *pure_texts*)))
    )


(hunchentoot:define-easy-handler (broadcast_text :uri "/brd_txt") (text)
    ( if ( = (length *peers*) 0)
        "NIL"
        (progn
        (loop for node in *peers* do 
            (handler-case
                (progn
                    (dex:get (makeuri_with_args node "recv_txt" `(("msg" ,text)))
                        :read-timeout 5
                        :connect-timeout 3
                        ))
                (error (e)
                    (declare (ignore e))
                    "ERR")))
        "OK")))


(hunchentoot:define-easy-handler (add_peer :uri "/add_peer") (peer)
    (handler-case
        (progn
            (dex:get (makeuri peer "ping")
                :read-timeout 1
                :connect-timeout 1)
                (pushnew peer *peers* :test #'string=)
            "OK")
        (error (e)
            (declare (ignore e))
                "NIL")))


(hunchentoot:start *server*)

(format t "Server Started~%")