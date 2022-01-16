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
; =====================================================================
; average damping
; average-damp wrap function f
(define (average x y) (/ (+ x y) 2.0))
(define (average-damp f)
    (lambda (x) (average (f x) x)) ; return a function
)
; =====================================================================

; procedure as [First-Class citizen], aka functional programming language.
; bring us higher abstraction level.
; abstract a general procedure that do transfrom and get fixed point.
(define (fixed-point-of-transfrom g transform guess)
    (fixed-point (transform g) guess)
)

; ======================= test: square root ============================
(define (square x) (* x x))

; avaerage damping
; fixed point of y -> x/y, use average damping, y -> (x/y + x)/2
(define (mysqrt1 x)
    (fixed-point-of-transfrom (lambda (y) (/ x y))
                              average-damp
                              1.0)
)

; Newton's method
; zero point of y^2-x, newton transform to fixed point x - g(x)/Dg(x)
(define (mysqrt2 x)
    (fixed-point-of-transfrom (lambda (y) (- (square y) x))
                              newton-transform
                              1.0)
)

; test
(mysqrt1 (square 101232.012340283))
(mysqrt2 (square 101232.012340283))

; looks we got a precision problem in newton' method when the number is too big.
; example: (square 10123245.012340283)
; (mysqrt2 (square 10123245.012340283))
