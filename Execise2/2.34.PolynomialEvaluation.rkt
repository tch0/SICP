#lang sicp

; accumulate (from right to left, aka foldr)
(define (accumulate op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (accumulate op initial (cdr sequence)))
    )
)
; ====================================================================================

; using Horner's Rule calculate Polynomial.
; 也即是秦九韶算法

; calculate a(n)*x^n + a(n-1)*x^(n-1) + ... + a1*x + a0
; equals to : ((an*x + a(n-1))x + ... + a1)*x + a0

; coefficient-sequence : (a0 a1 .. an)
(define (polynomial x coefficient-sequence)
    (accumulate (lambda (coeff res) (+ (* res x) coeff)) 0 coefficient-sequence)
)

; test
; 3x^2 + 2x + 1 : x = 1
(polynomial 1 (list 1 2 3)) ; 6
; 1 + 3x + 5x^3 + x^5 : x = 2
(polynomial 2 (list 1 3 0 5 0 1)) ; 79