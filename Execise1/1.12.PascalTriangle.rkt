#lang sicp

; pascal triangle
; C(n, a) = 1, a = 0 or a = n
;           C(n-1, a) + C(n, a-1), else

; recursion
(define (triangle n a)
    (if (or (= a 0) (= a n))
        1
        (+ (triangle (- n 1) a)
           (triangle (- n 1) (- a 1)))
    )
)

; test
(triangle 10 2)