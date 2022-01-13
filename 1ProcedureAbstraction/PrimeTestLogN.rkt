#lang sicp

; Fermat's Little Theorem
; p is prime, a is any natural number. then a^p === a (mod p)
; means that a^p % p = a % p

; 利用费马小定理检查一个数是否是质数，是必要非充分条件，
; 对整数n，随机取a<n，检查a^n mod n是否等于n，如果不等则一定不是质数，等则是质数概率很大。
; 卡迈克尔数(Carmichael number)：能够骗过费马检查的合数，最小的几个是561,1105,1729,2465,2821,6601...

; base ^ exp % m
; quick exp
(define (expmod base exp m)
    (define (square x) (* x x))
    (cond ((= exp 0) 1)
          ((even? exp) (remainder (square (expmod base (/ exp 2) m))
                                  m))
          (else (remainder (* base (expmod base (- exp 1) m))
                           m))
    )
)

; probability method of prime test : fermat test 费马检查
; (random n) : generate number from 0 to n-1
(define (fermat-test n)
    (define (try-it a)
        (= (expmod a n n) a)
    )
    (try-it (+ 1 (random (- n 1)))) ; try number from 1 to n-1 (inclusive)
)

; fast prime test is a probablity test, only have correctness of a high probablity, not guarantee to be a prime number.
; 费马检查是概率算法，检查次数越多，是质数概率越高，返回true也并不一定就是质数，不过是质数的概率非常高。
; time complexity: O(times * logN)
(define (fast-prime? n times)
    (cond ((= times 0) true)
          ((fermat-test n) (fast-prime? n (- times 1)))
          (else false)
    )
)

(fast-prime? 100 1)
(fast-prime? 561 100) ; #t, but 561 is a Carmichael number, not a prime number.