#lang sicp

; O(LogN) time complexity get Fibonacci(N)
; define transfrom T: a <- a+b, b <- a
; T^n will get Fibonacci(n+1) and Fibonacci(n)

; or use quick power of matrix
(define (fibonacci n)
    (fib-iter 1 0 0 1 n)
)
(define (square x) (* x x))

(define (fib-iter a b p q n)
    (cond ((= n 0)
            b)
          ((even? n)
            (fib-iter a
                      b
                      (+ (square p) (square q))     ; calculate p' = p^2 + q^2
                      (+ (* 2 p q) (square q))      ; calcualte q' = 2pq + q^2
                      (/ n 2)))
          (else
            (fib-iter (+ (* b q) (* a q) (* a p))
                      (+ (* b p) (* a q))
                      p
                      q
                      (- n 1))
          )
    )
)

(fibonacci 1000)