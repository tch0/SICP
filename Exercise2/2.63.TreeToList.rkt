#lang sicp

; from 2DataAbstraction/P106.BinaryTreeAsSet.rkt
(define (entry tree) (car tree)) ; first
(define (left-branch tree) (cadr tree)) ; second 
(define (right-branch tree) (caddr tree)) ; thrid
(define (make-tree root left right) (list root left right))


; convert tree to list

; 1: use append, O(nlogn)
(define (tree->list-1 tree)
    (if (null? tree)
        nil
        (append (tree->list-1 (left-branch tree))
                (cons (entry tree)
                      (tree->list-1 (right-branch tree))))
    )
)

; 2: traverse and copy, O(n)
(define (tree->list-2 tree)
    (define (copy-to-list tree result-list)
        (if (null? tree)
            result-list
            (copy-to-list (left-branch tree)
                          (cons (entry tree)
                                (copy-to-list (right-branch tree)
                                              result-list))
            )
        )
    )
    (copy-to-list tree nil)
)

; test
; tree 1
;     7
;    / \
;   3   9
;  / \   \
; 1   5   11
(define test-tree1
    (make-tree 7
               (make-tree 3 (make-tree 1 nil nil) (make-tree 5 nil nil))
               (make-tree 9 nil (make-tree 11 nil nil)))
)
; or '(7 (3 (1 () ()) (5 () ())) (9 () (11 () ())))

; tree 2
;    3
;   / \
;  1   7
;     / \
;    5   9
;         \
;         11
(define test-tree2 '(3 (1 () ()) (7 (5 () ()) (9 () (11 () ())))))

; tree 3
;       5
;      / \
;     3   9
;    /   / \
;   1   7  11
(define test-tree3 '(5 (3 (1 () ()) ()) (9 (7 () ()) (11 () ()))))

(tree->list-1 test-tree1)
(tree->list-1 test-tree2)
(tree->list-1 test-tree3)
(tree->list-2 test-tree1)
(tree->list-2 test-tree2)
(tree->list-2 test-tree3)