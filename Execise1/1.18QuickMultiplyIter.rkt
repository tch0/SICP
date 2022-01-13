#lang sicp

; just like quick power, use addition to implement multiply of integer
; imagine that we do not have multiplication, only have addition.

; a * b = (a * 2) * (b / 2), b is even
;         a + a * (b - 1), b is odd

(define (halve x)
    (/ x 2)
)

(define (double x)
    (+ x x)
)

; iteration
(define (* a b)
    (define (mul-iter summution a b)
        (cond ((<= b 0) summution)
              ((even? b) (mul-iter summution (double a) (halve b)))
              (else (mul-iter (+ a summution) a (- b 1)))
        )
    )
    (mul-iter 0 a b)
)

(* 33 179) ; 5907