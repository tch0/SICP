#lang sicp

; ==========================================================================
; expmod from fast prime test
(define (expmod base exp m)
    (define (square x) (* x x))
    (cond ((= exp 0) 1)
          ((even? exp) (remainder (square (expmod base (/ exp 2) m))
                                  m))
          (else (remainder (* base (expmod base (- exp 1) m))
                           m))
    )
)

; prime? from prime test
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

; a^n % n =? a % n, 同余检测
(define (congruent? a n)
    (= (expmod a n n) a))

; test whether a number is Carmichael number or a prime.
(define (carmichael-test n)
    (define (test-iter a n)
        (cond ((= a n) #t)
              ((congruent? a n) (test-iter (+ a 1) n))
              (else #f)
        )
    )
    (test-iter 1 n)
)

(define (test-carmichael n)
    (display n)
    (if (and (not (prime? n)) (carmichael-test n))
        (display " is a ")
        (display " is not a ")
    )
    (display "Carmichael number.")
    (newline)
)

; Carmichael numnbers
(test-carmichael 561)
(test-carmichael 1105)
(test-carmichael 1729)
(test-carmichael 2465)
(test-carmichael 2821)
(test-carmichael 6601)

; not carmichael nubmer
(test-carmichael 100)
(test-carmichael 97)