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
; =====================================================================

; use Newton's method approach the root of equation x^3 + ax^2 + bx + c = 0
(define (cube x) (* x x x))
(define (square x) (* x x))
(define (cubic a b c)
    (lambda (x)
        (+ (cube x)
           (* a (square x))
           (* b x)
           c)
    )
)

(newton-method (cubic 0 0 -1) 1.0) ; 1
(newton-method (cubic 1 1 1) 1.0) ; -1