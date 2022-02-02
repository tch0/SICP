#lang sicp

; from 2DataAbstraction/P106.BinaryTreeAsSet.rkt
(define (entry tree) (car tree)) ; first
(define (left-branch tree) (cadr tree)) ; second 
(define (right-branch tree) (caddr tree)) ; thrid
(define (make-tree root left right) (list root left right))


; convert list to balanced tree
(define (list->tree elements)
    (car (partial-tree elements (length elements)))
)

; construct pre-n elements of list to balanced tree
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

(list->tree '(1 3 5 7 9 11))
;       5
;     /   \
;    1     9
;     \   / \
;      3 7  11