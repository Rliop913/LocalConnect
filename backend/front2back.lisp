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
            (dolist (p *peers*)
                (dolist ( gotpeer (first (parse-csv (dex:get (makeuri p "list-peers")))))
                    (pushnew gotpeer *peers* :test #'string=)))
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
    (let ((decoded (hunchentoot:url-decode file :utf-8 nil)))
        (if (member decoded *localfiles* :test #'string=)
            (if (probe-file decoded)
                (progn
                        (setf (hunchentoot:header-out :content-disposition)
                            (format nil "attachment; filename=\"~A\"" (file-namestring decoded)))
                        (hunchentoot:handle-static-file decoded))
                (progn
                    (setf (hunchentoot:return-code*) 404)
                    "NOT FOUND"))
            (progn
                (setf (hunchentoot:return-code*) 404)
                (format nil "REJECTED-~A" decoded))))
    )

(hunchentoot:define-easy-handler (add-text :uri "/add-text") (text)
    ( if ( = (length *peers*) 0)
        "NIL"
        (progn
        (loop for node in *peers* do 
            (handler-case
                (progn
                    (pushnew text *pure_texts* :test #'string=)
                    (dex:post (makeuri node "recv_txt")
                        :content `(("txt" . ,text))))
                (error (e)
                    e)))
        "OK")))