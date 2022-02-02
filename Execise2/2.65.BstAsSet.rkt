#lang sicp

; ============================================================================
; from 2DataAbstraction/P106.BinaryTreeAsSet.rkt
(define (entry tree) (car tree)) ; first
(define (left-branch tree) (cadr tree)) ; second 
(define (right-branch tree) (caddr tree)) ; thrid
(define (make-tree root left right) (list root left right))

; ============================================================================
; from Execise2/2.63.TreeToList.rkt
; traverse and copy, O(n)
(define (tree->list tree)
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

; ============================================================================
; from Execise2/2.64.ConvertListToBalancedTree.rkt
; convert list to balanced tree
(define (list->tree elements)
    (car (partial-tree elements (length elements)))
)

; construct pre-n elements of list to a balanced tree
; return (the-balanced-tree . rest-elements)
; T(n) = 2T(n/2) + O(1) = O(n)
(define (partial-tree elements n)
    (if (= n 0)
        (cons nil elements)
        (let ((left-size (quotient (- n 1) 2)))
            (let ((left-result (partial-tree elements left-size)))
                (let ((left-tree (car left-result))
                      (non-left-elements (cdr left-result))
                      (right-size (- n (+ left-size 1))))
                    (let ((this-entry (car non-left-elements))
                          (right-result (partial-tree (cdr non-left-elements)
                                                      right-size)))
                        (let ((right-tree (car right-result))
                              (rest-elements (cdr right-result)))
                            (cons (make-tree this-entry left-tree right-tree)
                                  rest-elements)
                        )
                    )
                )
            )
        )
    )
)

; ============================================================================
; from 2DataAbstraction/P105.OrderedListAsSet.rkt
; intersection of two sets
; O(m+n)
(define (intersection-set-list set1 set2)
    (if (or (null? set1) (null? set2))
        nil
        (let ((x1 (car set1))
              (x2 (car set2)))
            (cond ((= x1 x2) (cons x1 (intersection-set-list (cdr set1) (cdr set2)))) ; de-duplicate
                  ((< x1 x2) (intersection-set-list (cdr set1) set2))
                  (else (intersection-set-list set1 (cdr set2))) ; x1 > x2
            )
        )
    )
)

; union of two sets
; O(m+n)
(define (union-set-list set1 set2)
    (cond ((null? set1) set2)
          ((null? set2) set1)
          (else (let ((x1 (car set1))
                      (x2 (car set2)))
                    (cond ((= x1 x2) (cons x1 (union-set-list (cdr set1) (cdr set2)))) ; de-duplicate
                          ((< x1 x2) (cons x1 (union-set-list (cdr set1) set2)))
                          (else (cons x2 (union-set-list set1 (cdr set2)))) ; x1 > x2
                    )
                )
          )
    )
)
; ============================================================================

; union-set, use bst
; convert bst to list, do union of ordered list then convert to bst.
; O(n)
(define (union-set set1 set2)
    (list->tree (union-set-list (tree->list set1)
                                (tree->list set2)))
)

; intersection-set, use bst
; convert bst to list, do intersection of oredered list, then convert to bst.
; O(n)
(define (intersection-set set1 set2)
    (list->tree (intersection-set-list (tree->list set1)
                                       (tree->list set2)))
)

; test
;   3
;  / \
; 2   4
;      \
;       5
(define test-set1 '(3 (2 () ()) (4 () (5 () ()))))
;   4
;  / \
; 2   6
(define test-set2 '(4 (2 () ()) (6 () ())))
(union-set test-set1 test-set2)
(intersection-set test-set1 test-set2)