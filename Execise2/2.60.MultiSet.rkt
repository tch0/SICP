#lang sicp

; multiset : set that can have duplicate elements.
(define (element-of-set? x set)
    (cond ((null? set) #f)
          ((equal? x (car set)) #t)
          (else (element-of-set? x (cdr set)))
    )
)

; O(1)
(define (adjoin-set x set)
    (cons x set)
)

; O(n)
(define (union-set set1 set2)
    (append set1 set2)
)

; auxiliary function
(define (remove-element-from-set x set)
    (define (remove-iter acc rest)
        (cond ((null? rest) acc)
              ((equal? x (car rest)) (union-set acc (cdr rest)))
              (else (remove-iter (adjoin-set (car rest) acc) (cdr rest)))
        )
    )
    (remove-iter nil set)
)

; O(mn)
(define (intersection-set set1 set2)
    (cond ((or (null? set1) (null? set2)) nil)
          ((element-of-set? (car set1) set2)
           (adjoin-set (car set1)
                       (intersection-set (cdr set1) (remove-element-from-set (car set1) set2))))
          (else (intersection-set (cdr set1) set2))
    )
)

; test
(define set1 '(1 2 3 4 1 1 2 5))
(define set2 '(1 4 1 2 2 0 0))
(element-of-set? 2 set1)
(adjoin-set 1 set1)
(union-set set1 set2)
(intersection-set set1 set2)