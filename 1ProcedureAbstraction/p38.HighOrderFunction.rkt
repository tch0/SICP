#lang sicp

; high order functions
; term and next are procedures
(define (sum term a next b)
    (if (> a b)
        0
        (+ (term a)
           (sum term (next a) next b))
    )
)

(define (square x) (* x x))
(define (cube x) (* x x x))

; 1 + 2 + ... + 100 = 5050
(sum identity 1 inc 100)

; PI/8 = 1/(1*3) + 1/(5*7) + 1/(9*11) + ...
(define (pi-sum a b)
    (define (pi-term n) (/ 1.0 (* n (+ n 2))))
    (define (pi-next n) (+ n 4))
    (* 8 (sum pi-term a pi-next b))
)

(pi-sum 1 1000) ; PI

; 数值积分：计算定积分的近似值
; \int_{a}^{b} f = [f(a+dx/2) + f(a+dx+dx/2) + f(a+2dx+dx/2) + ...] dx
(define (integral f a b dx)
    (define (add-dx x) (+ x dx))
    (* (sum f (+ a (/ dx 2)) add-dx b)
       dx)
)

; \int_0^1 x^3 = 0.25
(integral cube 0 1 0.1)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
