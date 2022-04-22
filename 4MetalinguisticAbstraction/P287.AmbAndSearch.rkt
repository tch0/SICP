#lang sicp

; auxiliary procedures
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

(define (require p)
    (if (not p) (amb))
)

(define (an-element-of items)
    (require (not (null? items)))
    (amb (car items) (an-element-of (cdr items)))
)

(define (prime-sum-pair list1 list2)
    (let ((a (an-element-of list1))
          (b (an-element-of list2)))
        (require (prime? (+ a b)))
        (list a b)
    )
)

(prime-sum-pair '(1 3 5 8) '(20 35 110))
(amb)
(amb)
(amb) ; amb tree exhausted