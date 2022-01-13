#lang sicp

; find smallest divisor of a integer
(define (smallest-divisor n)
    (find-divisor n 2)
)

(define (find-divisor n test-divisor)
    (define (square x) (* x x))
    (define (divides? a b) (= (remainder b a) 0)) ; b % a
    (cond ((> (square test-divisor) n) n)
          ((divides? test-divisor n) test-divisor)
          (else (find-divisor n (+ test-divisor 1)))
    )
)

; O(sqrt(N))
(define (prime? n)
    (= n (smallest-divisor n))
)

(prime? 97)
(prime? 100)
(smallest-divisor 199)
(smallest-divisor 1999)
(smallest-divisor 19999)