#lang sicp

; accumulate (from right to left, aka foldr)
(define (accumulate op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (accumulate op initial (cdr sequence)))
    )
)
; ====================================================================================

; accumulate list of list, result is a list
; (accumulate-n + 0 s), s is ((1 2 3) (4 5 6) (7 8 9) (10 11 12)) will get (22 26 30)
(define (accumulate-n op initial seqs)
    (if (null? (car seqs))
        nil
        (cons (accumulate op initial (map car seqs))
              (accumulate-n op initial (map cdr seqs)))
    )
)

; test
(define test-seq '((1 2 3) (4 5 6) (7 8 9) (10 11 12)))
(accumulate-n + 0 test-seq)