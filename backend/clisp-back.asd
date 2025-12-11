;;;; clisp-back.asd

(asdf:defsystem #:clisp-back
  :description "Describe clisp-back here"
  :author "Your Name <your.name@example.com>"
  :license  "MIT"
  :version "0.0.1"
  :depends-on (
    :cl-qrencode
    :hunchentoot
    :dexador)
  :serial t
  :components ((:file "package")
               (:file "clisp-back")))
