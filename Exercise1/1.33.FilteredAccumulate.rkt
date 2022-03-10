#lang sicp

; ==========================================================================
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
; ==========================================================================

(define (filtered-accumulate filter combiner null-value term a next b)
    (define (filtered-next a)
        (if (filter (next a))
            (next a)
            (filtered-next (next a))
        )
    )
    (define (iter a result)
        (if (> a b)
            result
            (iter (filtered-next a) (combiner (term a) result))
        )
    )
    (if (filter a)
        (iter a null-value)
        (iter (filtered-next a) null-value)
    )
)

; a)
(define (sum-of-primes a b)
    (filtered-accumulate prime? + 0 identity a inc b)
)

; b)
(define (co-prime? a b)
    (= 1 (gcd a b))
)

(define (product-of-co-primes n)
    (define (co-prime-with-n a) (co-prime? a n))
    (filtered-accumulate co-prime-with-n * 1 identity 1 inc n)
)

; test
(sum-of-primes 1 10) ; 18
(product-of-co-primes 10) ; 189
