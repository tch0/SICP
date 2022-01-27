#lang sicp

; tree-map: map all element of a tree
; use map
(define (tree-map proc tree)
    (cond ((null? tree) nil)
          ((list? tree) (map (lambda (x) (tree-map proc x)) tree))
          (else (proc tree))
    )
)

; recursion
(define (tree-map2 proc tree)
    (cond ((null? tree) nil)
          ((list? tree) (cons (tree-map2 proc (car tree)) (tree-map2 proc (cdr tree))))
          (else (proc tree))
    )
)

(define (square x) (* x x))
(define test-tree (list 1 2 (list 3 4 (list 5 6))))
(tree-map square test-tree)
(tree-map2 square test-tree)