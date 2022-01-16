#lang sicp

; binary serach a zero point of given function
; f(a) < 0 < f(b)
(define (search-zero-point f neg-point pos-point)
    (define (average a b) (/ (+ a b) 2))
    (define (close-enough? a b) (< (abs (- a b)) 0.001)) ; precision
    (let ((mid-point (average neg-point pos-point)))
        (if (close-enough? neg-point pos-point)
            mid-point
            (let ((test-value (f mid-point)))
                (cond ((positive? test-value) (search-zero-point f neg-point mid-point))
                      ((negative? test-value) (search-zero-point f mid-point pos-point))
                      (else mid-point)
                )
            )
        )
    )
)

; fault tolerance
(define (half-interval-search f a b)
    (let ((a-value (f a))
          (b-value (f b)))
        (cond ((and (negative? a-value) (positive? b-value)) (search-zero-point f a b))
              ((and (positive? a-value) (negative? b-value)) (search-zero-point f b a))
              ((= 0 a-value) a)
              ((= 0 b-value) b)
              (else (error "Values are not of opposite sign" a b))
        )
    )
)

; y = x^2 - 1
(define (y x) (- (* x x) 1))

; test
(search-zero-point y 0 3.0)
(search-zero-point y 0 -3.0)
(half-interval-search y 0 3.0)
(half-interval-search y 3.0 0)
(half-interval-search y -3.0 0)
(half-interval-search y 0 -3.0)

; f = x^3 - 2x - 3
(define (f x) (- (* x x x) (* 2 x) 3))
(half-interval-search f 1.0 2.0)