#lang sicp

; high order functions

; filter
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)

; accumulate (from right to left, aka foldr)
(define (accumulate op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (accumulate op initial (cdr sequence)))
    )
)

; ==============================================================================
; using accumulate implement sequence operations
(define (my-map p sequence)
    (accumulate (lambda (x y) (cons (p x) y)) nil sequence)
)

(define (my-append seq1 seq2)
    (accumulate cons seq2 seq1)
)

(define (my-length sequence)
    (accumulate (lambda (x y) (inc y)) 0 sequence)
)

; test
(define (square x) (* x x))
(my-map square (list 1 2 3 4))
(my-append (list 1 2 3) (list 4 5 6))
(my-length (list 1 2 3 4))