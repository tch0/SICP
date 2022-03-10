#lang sicp

; function composition
(define (compose outter inner)
    (lambda (x) (outter (inner x)))
)

(define (square x) (* x x))
((compose square inc) 6)