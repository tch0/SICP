#lang sicp

; =====================================================================
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

; 平均阻尼技术
; average damping
; average-damp wrap function f
(define (average x y) (/ (+ x y) 2.0))
(define (average-damp f)
    (lambda (x) (average (f x) x)) ; return a function
)

; square root, y^2 = x, aka y = x/y
(define (mysqrt x)
    (fixed-point (average-damp (lambda (y) (/ x y)))
                 1.0)
)

; cube root, y^3 = x, aka y = x/y^2
(define (cube-root x)
    (fixed-point (average-damp (lambda (y) (/ x (square y))))
                 1.0)
)

; helpers
(define (square x) (* x x))
(define (cube x) (* x x x))

; test
(mysqrt (square 1.213479123))
(cube-root (cube 10123784.1234))
