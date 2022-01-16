#lang sicp

; iteration
(define (sum term a next b)
    (define (sum-iter a result)
        (if (> a b)
            result
            (sum-iter (next a) (+ result (term a)))
        )
    )
    (sum-iter a 0)
)

; \sum_{i=1}^{50} i = 5050
(sum identity 1 inc 100)