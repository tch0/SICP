#lang sicp

; ==========================================================================
; O(LogN) probability prime test
(define (fast-prime? n times)
    (define (expmod base exp m)
        (define (square x) (* x x))
        (cond ((= exp 0) 1)
              ((even? exp) (remainder (square (expmod base (/ exp 2) m))
                                      m))
              (else (remainder (* base (expmod base (- exp 1) m))
                               m))
        )
    )
    (define (fermat-test n)
        (define (try-it a)
            (= (expmod a n n) a)
        )
        (try-it (+ 1 (random (- n 1)))) ; try number between 1 and n-1 (inclusive)
    )
    (cond ((= times 0) true)
          ((fermat-test n) (fast-prime? n (- times 1)))
          (else false)
    )
)

; do fast prime test 3 times randomly.
(define (prime? n)
    (fast-prime? n 3)
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
