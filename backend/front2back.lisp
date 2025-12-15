;;;; front2back.lisp

(in-package #:clisp-back)


(hunchentoot:define-easy-handler (add_peer :uri "/add_peer") (peer)
    (handler-case
        (progn
            (dex:get (makeuri peer "ping")
                :read-timeout 1
                :connect-timeout 1)
                (pushnew peer *peers* :test #'string=)
                (broadcast-peer-list)
            "OK")
        (error (e)
            (declare (ignore e))
                "NIL")))

(hunchentoot:define-easy-handler (add-file :uri "/add-file") (file)
    (if (probe-file file)
        (progn
            (fill-file-local file)
            (fill-file-glob (hunchentoot:local-addr*) file)
            (broadcast-file-list)
            "OK")
        (progn 
        (setf (hunchentoot:return-code*) 404) "NOT FOUND")))


(hunchentoot:define-easy-handler (download :uri "/download") (file)
    (if (member file *localfiles* :test #'string=)
        (if (probe-file file)
            (progn
                    (setf (hunchentoot:header-out :content-disposition)
                        (format nil "attachment; filename=\"~A\"" (file-namestring file)))
                    (hunchentoot:handle-static-file file))
            (progn
                (setf (hunchentoot:return-code*) 404)
                "NOT FOUND"))
        (progn
            (setf (hunchentoot:return-code*) 404)
            "REJECTED")))

(hunchentoot:define-easy-handler (add-text :uri "/add-text") (text)
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