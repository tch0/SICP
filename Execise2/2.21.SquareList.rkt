#lang sicp

(define (square x) (* x x))
; square every element of a list
(define (square-list items)
    (if (null? items)
        nil
        (cons (square (car items)) (square-list (cdr items)))
    )
)

(define (square-list2 items)
    (map square items)
)

(square-list (list 1 2 3))
(square-list2 (list 1 2 3))