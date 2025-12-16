;;;; clisp-back.asd

(asdf:defsystem #:clisp-back
  :description "LocalConnect Backend codebase"
  :author "Rliop913"
  :license  "MIT"
  :version "0.0.1"
  :depends-on (
    :cl-qrencode
    :hunchentoot
    :cl-csv
    :dexador)
  :serial t
  :components ((:file "package")
                (:file "utils")
                (:file "peer2peer")
                (:file "front2back")
               (:file "clisp-back")))
