#lang sicp

(define (sum term a next b)
    (if (> a b)
        0
        (+ (term a)
           (sum term (next a) next b))
    )
)

; \int_{a}^{b} f = [f(a+dx/2) + f(a+dx+dx/2) + f(a+2dx+dx/2) + ...] dx
; lambda expression
(define (integral f a b dx)
    (* (sum f
            (+ a (/ dx 2))
            (lambda (x) (+ x dx))
            b)
        dx)
)

; let expression, equals to call corresponding lamdba expression
(define (integral2 f a b dx)
    (let ((start (+ a (/ dx 2)))
          (add-dx (lambda (x) (+ x dx))))
         (* (sum f start add-dx b)
            dx))
)

; call lamdba expression
(define (integral3 f a b dx)
    ((lambda (start add-dx)
        (* (sum f start add-dx b)
           dx))
     (+ a (/ dx 2))
     (lambda (x) (+ x dx))
    )
)

; equivalent using of define
(define (integral4 f a b dx)
    (define start (+ a (/ dx 2)))
    (define (add-dx x) (+ x dx))
    (* (sum f start add-dx b)
       dx)
)

(define (cube x) (* x x x))

(integral cube 0 1 0.0001)
(integral2 cube 0 1 0.0001)
(integral3 cube 0 1 0.0001)
(integral4 cube 0 1 0.0001)
