#lang sicp

; recrusion
(define (accumulate combiner null-value term a next b)
    (if (> a b)
        null-value
        (combiner (term a)
                  (accumulate combiner null-value term (next a) next b))
    )
)

; iteration
(define (accumulate2 combiner null-value term a next b)
    (define (iter a result)
        (if (> a b)
            result
            (iter (next a) (combiner result (term a)))
        )
    )
    (iter a null-value)
)

(define (sum term a next b)
    (accumulate + 0 term a next b)
)

(define (product term a next b)
    (accumulate * 1 term a next b)
)

; test
(sum identity 1 inc 100)
(product identity 1 inc 10)
(accumulate2 + 0 identity 1 inc 100)
(accumulate2 * 1 identity 1 inc 10)