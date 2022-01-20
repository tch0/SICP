#lang sicp

; abstraction of interval
(define (make-interval a b)
    (if (> a b)
        (cons b a)
        (cons a b))
)
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

; operations of interval
(define (add-interval x y)
    (make-interval (+ (lower-bound x) (lower-bound y))
                   (+ (upper-bound x) (upper-bound y))
    )
)

(define (mul-interval x y)
    (let ((p1 (* (lower-bound x) (lower-bound y)))
          (p2 (* (lower-bound x) (upper-bound y)))
          (p3 (* (upper-bound x) (lower-bound y)))
          (p4 (* (upper-bound x) (upper-bound y))))
        (make-interval (min p1 p2 p3 p4)
                       (max p1 p2 p3 p4))
    )
)

(define (div-interval x y)
    (mul-interval x
                  (make-interval (/ 1.0 (upper-bound y))
                                 (/ 1.0 (lower-bound y)))
    )
)

(define a (make-interval 10 20))
(define b (make-interval 5 15))
(add-interval a b)
(mul-interval a b)
(div-interval a b)
(div-interval b a)