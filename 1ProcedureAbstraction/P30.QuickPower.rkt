#lang sicp

; quick power (Exponentiation by squaring)
; b^n = (b^(n/2)) ^ 2
;       b * b^(n-1)

(define (power a n)
    (define (square x) (* x x))
    (cond ((= n 0) 1)
          ((even? n) (square (power a (/ n 2))))
          (else (* a (power a (- n 1))))
    )
)

(power 2 100)