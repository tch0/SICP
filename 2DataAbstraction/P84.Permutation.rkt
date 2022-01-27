#lang sicp

; ============================================================================
; fold from Execise2/2.38.FoldLeft.rkt
(define (fold-right op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (fold-right op initial (cdr sequence)))
    )
)

(define (fold-left op initial sequence)
    (if (null? sequence)
        initial
        (fold-left op (op initial (car sequence)) (cdr sequence))
    )
)
; ============================================================================
; flatmap, map then append all sublist to one list
(define (flatmap proc seq)
    (fold-right append nil (map proc seq))
)
; ============================================================================
; filter
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)
; ============================================================================

; permutation of a set
(define (permutations s)
    (if (null? s)
        (list nil)
        (flatmap (lambda (x)
                    (map (lambda (p) (cons x p))
                         (permutations (remove x s))))
                 s)
    )
)
(define (remove item sequence)
    (filter (lambda (x) (not (= x item))) sequence)
)

; test
(permutations (list 1 2 3))