#lang sicp

; use procedure to implement pair
(define (mycons x y)
    (lambda (m) (m x y))
)
(define (mycar z)
    (z (lambda (p q) p))
)

(define (mycdr z)
    (z (lambda (p q) q))
)

; test
(define p (mycons 1 2))
(mycar p)
(mycdr p)