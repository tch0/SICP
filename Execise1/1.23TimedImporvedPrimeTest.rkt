#lang sicp

; ==========================================================================
; O(sqrt(N)) prime test procedure
; improve a little by do not divde by even numbers.
(define (prime? n)
    (define (next n)
        (if (= n 2)
            3
            (+ n 2))
    )
    (define (find-divisor n test-divisor)
        (define (square x) (* x x))
        (define (divides? a b) (= (remainder b a) 0)) ; b % a
        (cond ((> (square test-divisor) n) n)
              ((divides? test-divisor n) test-divisor)
              (else (find-divisor n (next test-divisor)))
        )
    )
    ; find smallest divisor of a integer
    (define (smallest-divisor n)
        (find-divisor n 2)
    )
    (= n (smallest-divisor n))
)
; ==========================================================================

(define (next-odd n)
    (if (odd? n)
        (+ n 2)
        (+ n 1))
)

(define (timed-prime-test n)
    (start-prime-test n (runtime))
)

(define (start-prime-test n start-time)
    (if (prime? n)
        (report-prime n (- (runtime) start-time))
    )
)

(define (report-prime n elapsed-time)
    (newline)
    (display n)
    (display " : ")
    (display elapsed-time)
    (display " us")
)

(define (generate-primes-from n count)
    (if (> count 0) (timed-prime-test n))
    (cond ((= count 0) (display ""))
          ((prime? n) (generate-primes-from (next-odd n) (- count 1)))
          (else (generate-primes-from (next-odd n) count))
    )
)

; find smallest 3 prime number that greater than 1000/10000/100000/1000000.
(define (search-for-primes n)
    (newline)
    (display "from ")
    (display n)
    (generate-primes-from n 3)
)

(search-for-primes 1000)
(search-for-primes 10000)
(search-for-primes 100000)
(search-for-primes 1000000)
(search-for-primes 10000000)
