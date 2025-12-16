(require :asdf)

(push (truename "./") asdf:*central-registry*)

(asdf:load-system :clisp-back)

(sb-ext:save-lisp-and-die "commonlisp-backend"
    :toplevel #'clisp-back:main
    :executable t)