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
; prime? from 1ProcedureAbstraction/P33.PrimeTest.rkt
; O(sqrt(N)) prime test procedure
(define (prime? n)
    (define (find-divisor n test-divisor)
        (define (square x) (* x x))
        (define (divides? a b) (= (remainder b a) 0)) ; b % a
        (cond ((> (square test-divisor) n) n)
              ((divides? test-divisor n) test-divisor)
              (else (find-divisor n (+ test-divisor 1)))
        )
    )
    ; find smallest divisor of a integer
    (define (smallest-divisor n)
        (find-divisor n 2)
    )
    (= n (smallest-divisor n))
)
; ============================================================================

; example
; 1 <= j < i <= n, find all (i, j, i+j) pairs(as a list) that i+j is prime number.

; integers from a to b
(define (enumerate-interval a b)
    (if (> a b)
        nil
        (cons a (enumerate-interval (+ a 1) b))
    )
)

; flatmap, map then append all sublist to one list
(define (flatmap proc seq)
    (fold-right append nil (map proc seq))
)

; get all (i, j) pairs that 1 <= j < i <= n
(define (get-ij-pairs n)
    (define (get-pair i)
        (map (lambda (j) (list i j))
             (enumerate-interval 1 (- i 1)))
    )
    (flatmap get-pair (enumerate-interval 1 n))
)

; calculate sum, get (i, j, i+j) pair
(define (make-pair-sum pair)
    (list (car pair) (cadr pair) (+ (car pair) (cadr pair)))
)

; condition: that sum is prime
(define (prime-sum? pair)
    (prime? (+ (car pair) (cadr pair)))
)

; final result
(define (prime-sum-pairs n)
    (map make-pair-sum (filter prime-sum? (get-ij-pairs n)))
)

; test
(enumerate-interval 1 10)
(prime-sum-pairs 10)