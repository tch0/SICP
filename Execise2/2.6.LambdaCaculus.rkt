#lang sicp

; Church encoding : https://en.wikipedia.org/wiki/Church_encoding
; a means of representing data and operators in the lambda calculus
; using procedure implement numbers
(define zero (lambda (f) (lambda (x) x)))
(define (add-1 n)
    (lambda (f) (lambda (x) (f ((n f) x))))
)

; apply zero and one to add-1
(add-1 zero) ; result: (lambda (f) (lambda (x) (f x))), call f one time
(define one (lambda (f) (lambda (x) (f x))))
(add-1 one) ; result: (lambda (f) (lambda (x) (f (f x)))), call f two times
(define two (lambda (f) (lambda (x) (f (f x)))))

; m + n
; observe add-1 carefully, not so hard to see the result.
(define (+ m n)
    (lambda (f)
        (lambda (x)
            ((m f) ((n f) x))
        )
    )
)

; output as numbers
(define (print-numbers n)
    ((n inc) 0)
)

; test
(print-numbers zero) ; 0
(print-numbers one) ; 1
(print-numbers two) ; 2
(print-numbers (+ (+ one two) two)) ; 5

; x ^ y
(define (expt x y)
    (y x)
)

; test
(define three (+ one two)) ; 3
(print-numbers (expt two three)) ; 2^3 = 8
(print-numbers (expt three two)) ; 3^2 = 9
(print-numbers (expt two (expt two (expt two two)))) ; 2^(2^(2^2)) = 2^16 = 65535

; so what about * / -?
; TODO : more about lambda calculus