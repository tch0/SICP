#lang sicp

; numerical integration: Simpson' rule
; \int_a^b f = h/3[y_0 + 4y_1 + 2y_2 + 4y_3 + 2y_4 + ... + 2y_{n-2} + 4y_{n-1} + y_n]
; h = (b-a) / n, n is a even number, y_k = f(a + kh)
; larger n, higher precision

(define (sum term a next b)
    (if (> a b)
        0
        (+ (term a)
           (sum term (next a) next b))
    )
)

(define (simpson-integral f a b n)
    (define h (/ (- b a) n))
    (define (y k) (f (+ a (* k h))))
    (define (simpson-term i)
        (cond ((= i 0) (y 0))
              ((= i n) (y n))
              ((even? i) (* 4.0 (y i)))
              (else (* 2.0 (y i)))
        )
    )
    (* (/ h 3.0) (sum simpson-term 0 inc n))
)

(define (cube x) (* x x x))
; result : 0.25
(simpson-integral cube 0 1 10)
(simpson-integral cube 0 1 100)
(simpson-integral cube 0 1 1000)
(simpson-integral cube 0 1 10000)
