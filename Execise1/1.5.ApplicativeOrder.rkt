#lang sicp

; judge applicative order or regular order
(define (p) (p))

(define (test x y)
    (if (= x 0)
        0
        y
    )
)

; if the implementation use applicative order, will cause infinite recursion.
; if regular order, will get 0
(test 0 (p))
