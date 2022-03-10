#lang sicp

; iteration(tail recursion) impletation of quick power
(define (power a n)
    (define (square x) (* x x))
    (define (power-iter product base exponent)
        (cond ((<= exponent 0) product)
              ((even? exponent) (power-iter product (square base) (/ exponent 2)))
              (else (power-iter (* product base) base (- exponent 1)))
        )
    )
    (power-iter 1 a n)
)

(power 2 100)