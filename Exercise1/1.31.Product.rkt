#lang sicp

; iteration
(define (product term a next b)
    (define (prod-iter a result)
        (if (> a b)
            result
            (prod-iter (next a) (* result (term a)))
        )
    )
    (prod-iter a 1)
)

; recursion
(define (product2 term a next b)
    (if (> a b)
        1
        (* (term a)
           (product2 term (next a) next b))
    )
)

(define (factorial n)
    (product identity 1 inc n)
)

(product identity 1 inc 10)
(product2 identity 1 inc 10)
(factorial 10)

; \pi / 4 = 2*4*4*6*6*8.../3*3*5*5*7*7...
; i = 3 to n, \prod ((i-1) * (i+1)) / i^2
(define (pi-term i)
    (/ (* (+ i 1) (- i 1))
        (* i i))
)
(define (pi-next i) (+ i 2))
(* 4.0 (product2 pi-term 3 pi-next 10))
(* 4.0 (product2 pi-term 3 pi-next 100))
(* 4.0 (product2 pi-term 3 pi-next 1000))
