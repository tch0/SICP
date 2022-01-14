#lang sicp

; newton iteration
; y = sqrt(x)
; guess y = 1, iterate y = (x / y + y) / 2

(define (sqrt-iter guess x)
    (if (good-enough? guess x)
        guess
        (sqrt-iter (improve guess x)
                   x
        )
    )
)

; (guess + x / guess) / 2
(define (improve guess x)
    (average guess (/ x guess))
)

(define (average x y)
    (/ (+ x y) 2)
)

; use ? to be the last char of predicate, just a convention
(define (good-enough? guess x)
    (< (abs (- (square guess) x)) 0.001)
)

(define (square x)
    (* x x)
)

(define (sqrt x)
    (sqrt-iter 1.0 x)
)

(sqrt-iter 1 10.0)
(sqrt 100)
(sqrt (+ 100 21))
(square (sqrt 1000))
