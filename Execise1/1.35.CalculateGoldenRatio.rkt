#lang sicp

(define tolerance 0.00001)
(define (fixed-point f first-guess)
    (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance)
    )
    (define (try guess)
        (let ((next (f guess)))
            (if (close-enough? guess next)
                next
                (try next)
            )
        )
    )
    (try first-guess)
)

; Exercise 1.35
; result: (1+sqrt(5)) / 2
; fixed point of x = 1 + 1/x [x^2 - x - 1 = 0]
(fixed-point (lambda (x) ( + 1 (/ 1 x))) 1.0)
(/ (+ 1 (sqrt 5)) 2)