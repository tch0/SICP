#lang sicp

; scale tree
(define (scale-tree tree factor)
    (cond ((null? tree) nil)
          ((list? tree) (cons (scale-tree (car tree) factor) (scale-tree (cdr tree) factor)))
          (else (* tree factor))
    )
)

; use lambda
(define (scale-tree2 tree factor)
    (map (lambda (sub-tree)
            (if (list? sub-tree)
                (scale-tree2 sub-tree factor)
                (* sub-tree factor))
        )
        tree
    )
)

; map is enough
(define (scale-tree3 tree factor)
    (if (list? tree)
        (map (lambda (x) (scale-tree3 x factor)) tree)
        (* factor tree)
    )
)

(define test-tree (list 1 2 (list 3 4 (list 5 6))))
(scale-tree test-tree 2)
(scale-tree2 test-tree 2)
(scale-tree3 test-tree 2)