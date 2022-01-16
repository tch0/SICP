#lang sicp

; =====================================================================
; find fixed point
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
; =====================================================================

; Newton's method
; aka Newton–Raphson method, is a root-finding algorithm which produces successively
; better approximations to the roots (or zeroes) of a real-valued function.
; f(x) = x - g(x)/Dg(x)
; the root of g(x) = 0 is the fixed point of function f(x)

; derivative
; definition of derivative
; Dg(x) = [g(x+dx) - g(x)] / dx
(define dx 0.00001)
(define (derivative g)
    (lambda (x)
        (/ (- (g (+ x dx)) (g x))
           dx)
    )
)

; newton's transfrom
; transform g(x) to x - g(x)/Dg(x)
(define (newton-transform g)
    (lambda (x)
        (- x (/ (g x) ((derivative g) x)))
    )
)
; newton's method
(define (newton-method g guess)
    (fixed-point (newton-transform g) guess)
)

; test of derivative
(define (square x) (* x x))
(define (cube x) (* x x x))
((derivative cube) 5) ; 2x^2, 75.0

; test newton's method
; square root, equation: y^2 - x = 0
(define (mysqrt x)
    (newton-method (lambda (y) (- (square y) x))
                   1.0) 
)

; test of square root
(mysqrt (square 195832.14457464768))
(mysqrt (square 1012392.012340283))
