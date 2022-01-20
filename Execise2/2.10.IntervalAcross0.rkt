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
(define (mul-interval x y)
    (let ((p1 (* (lower-bound x) (lower-bound y)))
          (p2 (* (lower-bound x) (upper-bound y)))
          (p3 (* (upper-bound x) (lower-bound y)))
          (p4 (* (upper-bound x) (upper-bound y))))
        (make-interval (min p1 p2 p3 p4)
                       (max p1 p2 p3 p4))
    )
)

; interval across 0 like (-1, 2)
(define (interval-across0 x)
    (<= (* (lower-bound x) (upper-bound x))
        0.0)
)

(define (div-interval x y)
    (if (interval-across0 y)
        (error "error : interval across 0" y)
    )
    (mul-interval x
      (make-interval (/ 1.0 (upper-bound y))
                     (/ 1.0 (lower-bound y)))
    )
)

; test
(define x (make-interval 5 -5))
(div-interval x (make-interval 1 2))
(div-interval x (make-interval 1 -1))