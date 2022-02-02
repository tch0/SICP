#lang sicp

; representation of set : use unsorted list

; element is belong to set?
; O(n)
(define (element-of-set? x set)
    (cond ((null? set) #f)
          ((equal? x (car set)) #t)
          (else (element-of-set? x (cdr set)))
    )
)

; add element x to set
; O(n)
(define (adjoin-set x set)
    (if (element-of-set? x set)
        set
        (cons x set)
    )
)

; intersection of two sets
; O(mn)
(define (intersection-set set1 set2)
    (cond ((or (null? set1) (null? set2)) '())
          ((element-of-set? (car set1) set2)
           (cons (car set1) (intersection-set (cdr set1) set2)))
          (else (intersection-set (cdr set1) set2))
    )
)

; union of two sets
; O(mn)
(define (union-set set1 set2)
    (cond ((null? set1) set2)
          ((null? set2) set1)
          ((element-of-set? (car set1) set2)
           (union-set (cdr set1) set2))
          (else (cons (car set1) (union-set (cdr set1) set2)))
    )
)

; test
(define set1 '(1 2 3 4 5))
(define set2 '(3 4 5 8 9 0))
(element-of-set? 4 set1)
(adjoin-set 10 set1)
(intersection-set set1 set2)
(union-set set1 set2)