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

; using accumulate to count leaves
(define (count-leaves tree)
    (accumulate + 0 (map (lambda (x) (if (list? x) (count-leaves x) x)) tree))
)

; test
(count-leaves (list 1 2 (list 3 4 (list 5 6))))