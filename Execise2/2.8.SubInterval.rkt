#lang sicp

; substraction of interval
(define (make-interval a b)
    (if (> a b)
        (cons b a)
        (cons a b))
)
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

(define (sub-interval x y)
    (make-interval (- (lower-bound x) (upper-bound y))
                   (- (upper-bound x) (lower-bound y))
    )
)

(sub-interval (make-interval 10 20) (make-interval 5 15))