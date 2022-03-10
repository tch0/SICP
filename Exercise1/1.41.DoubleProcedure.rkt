#lang sicp

(define (double f)
    (lambda (x) (f (f x)))
)

((double inc) 2)
(((double (double double)) inc) 5) ; 5+16