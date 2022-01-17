#lang sicp

; the abstraction of iterative improving
(define (iterative-improve close-enough? improve)
    (lambda (first-guess)
        (define (try guess)
            (let ((next (improve guess)))
                (if (close-enough? guess next)
                    next
                    (try next)
                )
            )
        )
        (try first-guess)
    )
)

; aid functions
(define (square x) (* x x))
(define (average x y) (/ (+ x y) 2.0))

; square root
(define (mysqrt x)
    (define dx 0.00001)
    (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) dx)
    )
    (define (improve guess)
        (average guess (/ x guess))
    )
    ((iterative-improve close-enough? improve) 1.0)
)


; find fixed point
(define (fixed-point f first-guess)
    (define tolerance 0.00001)
    (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance)
    )
    ((iterative-improve close-enough? f) first-guess)
)

; use fixed point define square root
(define (mysqrt2 x)
    (fixed-point (lambda (y) (average y (/ x y)))
                 1.0)
)

(fixed-point cos 1.0)
(mysqrt 10.0)
(mysqrt2 10.0)