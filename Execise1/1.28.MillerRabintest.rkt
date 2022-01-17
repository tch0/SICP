#lang sicp

; expmod from fast prime test
(define (expmod base exp m)
    (define (square x) (* x x))
    (define (non-trivial-square-root? a n)
        (and (not (= a 1))
             (not (= a (- n 1)))
             (= 1 (remainder (square a) n))
        )
    )
    (cond ((= exp 0) 1)
          ((non-trivial-square-root? base m) 0) ; base^2 % m == 1, added for Miller-Rabin test, 0 represent non-prime
          ((even? exp) (remainder (square (expmod base (/ exp 2) m))
                                  m))
          (else (remainder (* base (expmod base (- exp 1) m))
                           m))
    )
)

; Miller-Rabin test, improving of Fermat tset
(define (miller-rabin-test n)
    (define (try-it a)
        (= (expmod a (- n 1) n) 1) ; a^(n-1) % n = 1
    )
    (try-it (+ 1 (random (- n 1)))) ; from 1 to n-1 (inclusive)
)

(define (miller-rabin-times-test n count)
    (cond ((= count 0) #t)
          ((miller-rabin-test n) (miller-rabin-times-test n (- count 1)))
          (else #f)
    )
)

; Miller-Rabin test is also a probablity test, but have higher correctness than Fermat test.
; test n/2 times to make sure , because there is only the probability of 1/2 to get non trivial square root.
; 对很大的数，做n/2次并不实际，所以其实也是概率测试，只是准确度比费马测试更好，误报概率比较低，已经完全可以使用。
; final complexity: O(NlogN)
(define (miller-rabin-prime? n)
    (miller-rabin-times-test n (ceiling (/ n 2)))
)

; primes, all true
(miller-rabin-prime? 3)
(miller-rabin-prime? 5)
(miller-rabin-prime? 97)
(miller-rabin-prime? 1000033)
(miller-rabin-prime? 1000037)
(miller-rabin-times-test 10000019 20)
(miller-rabin-times-test 10000079 20)
(miller-rabin-times-test 10000103 20)
(newline)

; not prime
(miller-rabin-prime? 100)
(miller-rabin-prime? 10234780)
(newline)

; Carmichael number, all false
(miller-rabin-prime? 561 )
(miller-rabin-prime? 1105)
(miller-rabin-prime? 1729)
(miller-rabin-prime? 2465)
(miller-rabin-prime? 2821)
(miller-rabin-prime? 6601)
