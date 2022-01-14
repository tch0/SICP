#lang sicp

; normal recursion
(define (factorial x)
    (if (<= x 1)
        1
        (* x (factorial (- x 1)))
    )
)

; iteration (tail recursion)
; recursion in syntax, iteration in calculation procedure
(define (factorial2 x)
    (define (fact-iter product counter max-count)
        (if (> counter max-count)
            product
            (fact-iter (* product counter)
                       (+ counter 1)
                       max-count)
        )
    )
    (fact-iter 1 1 x)
)

(factorial 10)
(factorial2 10)