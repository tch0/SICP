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
; filter from 2DataAbstraction/P78.SequenceAsInterface.rkt
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)
; ============================================================================
; flatmap from 2DataAbstraction/P83.NestedMapping.rkt
(define (flatmap proc seq)
    (fold-right append nil (map proc seq))
)
; ============================================================================
; permutations from 2DataAbstraction/P84.Permutation.rkt
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
; ============================================================================
; enumerate-interval from 2DataAbstraction/P83.NestedMapping.rkt
(define (enumerate-interval a b)
    (if (> a b)
        nil
        (cons a (enumerate-interval (+ a 1) b))
    )
)
; ============================================================================

; i != j != k <= n, i + j + k = s, find all (i, j, k) pairs
; strategy: generate all (i, j, k) pairs that, i < j <= k and i+j+k = s
; then get permutations for all pairs.

; generate all (i,j,k) pairs that i < j < k <= n
(define (unique-pairs k)
    (define (get-pairs k)
        (map (lambda (j) (list j k))
             (enumerate-interval 1 (- k 1)))
    )
    (flatmap get-pairs (enumerate-interval 1 k))
)

(define (unique-ijk-triples n)
    (define (get-pairs jkpair)
        (map (lambda (i) (cons i jkpair))
             (enumerate-interval 1 (- (car jkpair) 1)))
    )
    (flatmap get-pairs (unique-pairs n))
)

; euqals to unique-ijk-triples
(define (unique-triples n)
    (flatmap (lambda (k)
                (flatmap (lambda (j)
                            (map (lambda (i) (list i j k))
                                 (enumerate-interval 1 (- j 1))))
                         (enumerate-interval 1 (- k 1))))
             (enumerate-interval 1 n)
    )
)

; filter those not equal to s
(define (triples-sum-euqal-to-s n s)
    (filter (lambda (seq) (= (fold-right + 0 seq) s)) (unique-ijk-triples n))
)

; permutations of pairs
(define (triples-permutation n s)
    (flatmap permutations (triples-sum-euqal-to-s n s))
)

; test
(unique-ijk-triples 5)
(unique-triples 5)
(triples-sum-euqal-to-s 5 10)
(triples-permutation 5 10)

; more generalized, k-tuples of [1..n]
(define (unique-tuples n k)
    (cond ((< n k) nil)
          ((= k 0) (list nil))
          (else (append (unique-tuples (- n 1) k)
                        (map (lambda (tuple) (cons n tuple))
                             (unique-tuples (- n 1) (- k 1))))
          )
    )
)

; test
(unique-tuples 5 3)