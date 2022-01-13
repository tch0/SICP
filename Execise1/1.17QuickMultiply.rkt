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

; recursion
(define (* a b)
    (cond ((<= b 0) 0)
          ((even? b) (* (double a) (halve b)))
          (else (+ a (* a (- b 1))))
    )
)

(* 33 179) ; 5907