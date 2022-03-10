#lang sicp

; calculate f(n) = n, n < 3
;                  f(n-1) + 2f(n-2) + 3f(n-3), n >= 3
; recursion
(define (f n)
    (if (< n 3)
        n
        (+ (f (- n 1))
           (* (f (- n 2)) 2)
           (* (f (- n 3)) 3))
    )
)

; iteration
(define (f2 n)
    (define (f-iter a b c count)
        (if (<= count 0)
            c
            (f-iter (+ a (* b 2) (* c 3))
                    a
                    b
                    (- count 1))
        )
    )
    (f-iter 2 1 0 n)
)

(f  20)
(f2 20)
(f2 100)