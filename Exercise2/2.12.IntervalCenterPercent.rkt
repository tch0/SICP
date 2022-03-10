#lang sicp

; abstraction of interval
(define (make-interval a b)
    (if (> a b)
        (cons b a)
        (cons a b))
)
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

; center and width
(define (make-center-width c w)
    (make-interval (- c w) (+ c w))
)
(define (center i)
    (/ (+ (lower-bound i) (upper-bound i)) 2)
)
(define (width i)
    (/ (- (lower-bound i) (upper-bound i)) 2)
)

; center and percent
; percent is between 0 and 1.0
(define (make-center-percent c p)
    (make-center-width c (* p c))
)
(define (percent i)
    (/ (width i) (center i))
)

; test
(make-center-percent 10 0.15)