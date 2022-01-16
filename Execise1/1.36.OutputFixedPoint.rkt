#lang sicp

; fixed point, the point that f(x) = x
; try to iterate f(x), f(f(x)), f(f(f(x))) ..., if convergence, x is the fixed point

; ouput the middle result of every step
(define tolerance 0.00001)
(define (fixed-point f first-guess)
    (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance)
    )
    (define (try guess step)
        (display "step ")
        (display step)
        (display ": ")
        (display (f guess))
        (newline)
        (let ((next (f guess)))
            (if (close-enough? guess next)
                next
                (try next (+ step 1))
            )
        )
    )
    (try first-guess 1)
)

(define (f x) (/ (log 1000) (log x)))
; search root of x^x = 1000
; by finding the fixed point of x = log1000 / log(x)
; 33 steps
(fixed-point f 10.0)

; use average damping
; x = (log1000 / logx + x) / 2
; 10 steps
(newline)
(define (average x y) (/ (+ x y) 2.0))
(define (average-damp f)
    (lambda (x) (average x (f x)))
)
(fixed-point (average-damp f) 10.0)
