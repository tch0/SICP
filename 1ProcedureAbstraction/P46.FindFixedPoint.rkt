#lang sicp

; fixed point, the point that f(x) = x
; try to iterate f(x), f(f(x)), f(f(f(x))) ..., if convergence, x is the fixed point

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

; y = cosx
(fixed-point cos 1.0) ; 0.7390822985224024
; y = sinx + cosx
(fixed-point (lambda (x) (+ (sin x) (cos x))) 1.0)


; use fixed point to get square root
; search fixed point of y = (1/2)(y + x/y) [equivalent form of y = x/y]
; 这种取逼近一个解的一系列值的平均值的做法，叫做平均阻尼技术。
(define (average x y) (/ (+ x y) 2.0))
(define (mysqrt x)
    (fixed-point (lambda (y) (average y (/ x y))) x)
)
(mysqrt 2.0) ; 1.4142135623746899

; Exercise 1.35
; result: (1+sqrt(5)) / 2
(fixed-point (lambda (x) ( + 1 (/ 1 x))) 1.0)
(/ (+ 1 (mysqrt 5)) 2)