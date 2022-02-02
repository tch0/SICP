#lang sicp

; use ordered list represent set
; list in asending order
; maybe should use a self-defined compare function for element to get higher generality.

; element is belong to set?
; O(n)
(define (element-of-set? x set)
    (cond ((null? set) #f)
          ((= x (car set)) #t)
          ((< x (car set)) #f)
          (else (element-of-set? x (cdr set))) ; x > (car set)
    )
)

; add element x to set
; O(n)
(define (adjoin-set x set)
    (cond ((null? set) (list x))
          ((= x (car set)) set) ; de-duplicate
          ((< x (car set)) (cons x set))
          (else (cons (car set) (adjoin-set x (cdr set)))) ; x > (car set)
    )
)

; intersection of two sets
; O(m+n)
(define (intersection-set set1 set2)
    (if (or (null? set1) (null? set2))
        nil
        (let ((x1 (car set1))
              (x2 (car set2)))
            (cond ((= x1 x2) (cons x1 (intersection-set (cdr set1) (cdr set2)))) ; de-duplicate
                  ((< x1 x2) (intersection-set (cdr set1) set2))
                  (else (intersection-set set1 (cdr set2))) ; x1 > x2
            )
        )
    )
)

; union of two sets
; O(m+n)
(define (union-set set1 set2)
    (cond ((null? set1) set2)
          ((null? set2) set1)
          (else (let ((x1 (car set1))
                      (x2 (car set2)))
                    (cond ((= x1 x2) (cons x1 (union-set (cdr set1) (cdr set2)))) ; de-duplicate
                          ((< x1 x2) (cons x1 (union-set (cdr set1) set2)))
                          (else (cons x2 (union-set set1 (cdr set2)))) ; x1 > x2
                    )
                )
          )
    )
)

; test
(define set1 '(1 2 3 4 5))
(define set2 '(0 1 3 5 7 9 100))
(element-of-set? 100 set2)
(adjoin-set 10 set2)
(intersection-set set1 set2)
(union-set set1 set2)