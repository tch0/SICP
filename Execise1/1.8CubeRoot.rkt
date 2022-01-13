#lang sicp

; root of cube
; y ^ 3 = x
; newton iteration: (x / (y^2) + 2y) / 3

(define (cube-root-iter guess change x)
    (define new-guess (improve guess x))
    (if (good-enough? guess change)
        guess
        (cube-root-iter new-guess
                        (abs (- new-guess guess))
                        x)
    )
)

(define (improve guess x)
    (/ (+ (/ x (* guess guess)) (* 2.0 guess))
       3.0)
)

; use ? to be the last char of name of predicate, just a convention
(define (good-enough? guess change)
    (< (/ change guess) 0.001)
)

(define (cube-root x)
    (cube-root-iter 1.0 1.0 x)
)

(define (cube x)
    (* x x x)
)

(cube-root-iter 1.0 1.0 1.0)
(cube-root (cube 10.72134))
