#lang sicp

; square every element of a tree
; version 1 : use map
(define (square x) (* x x))
(define (square-tree tree)
    (if (list? tree)
        (map square-tree tree)
        (square tree)
    )
)

; version 2 : just recursion
(define (square-tree2 tree)
    (cond ((null? tree) nil)
          ((list? tree) (cons (square-tree2 (car tree)) (square-tree2 (cdr tree))))
          (else (square tree))
    )
)

; test
(define x (list 1 2 (list 3 4 (list 5 6))))
(square-tree x)
(square-tree2 x)