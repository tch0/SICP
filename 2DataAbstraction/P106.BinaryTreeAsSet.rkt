#lang sicp

; use binary search tree represent set

; bst type and selector
; nil as empty tree
(define (entry tree) (car tree)) ; first
(define (left-branch tree) (cadr tree)) ; second 
(define (right-branch tree) (caddr tree)) ; thrid

(define (make-tree root left right) (list root left right))

; element is belong to set?
; O(logn) ideally, O(n) wrost
(define (element-of-set? x set)
    (cond ((null? set) #f)
          ((= x (entry set)) #t)
          ((< x (entry set)) (element-of-set? x (left-branch set)))
          (else (element-of-set? x (right-branch set)))
    )
)

; add element x to set
; O(logn) ideally, O(n) wrost
(define (adjoin-set x set)
    (cond ((null? set) (make-tree x nil nil))
          ((= x (entry set)) set)
          ((< x (entry set)) (make-tree (entry set)
                                        (adjoin-set x (left-branch set))
                                        (right-branch set)))
          (else (make-tree (entry set)
                           (left-branch set)
                           (adjoin-set x (right-branch set))))
    )
)

; test
(define test-set '(3 (2 () ()) (4 () (5 () ()))))
(element-of-set? 5 test-set)
(adjoin-set 10 test-set)