#lang sicp

; arithmetic of rational numbers
; x = n / d
(define (make-rat n d)
    (let ((g (gcd n d)))
        (cons (/ n g) (/ d g))
    )
)
(define (numer x) (car x))
(define (denom x) (cdr x))

; arithmetic operations: +-*/ =?
; n1/d1 + n2/d2 = (n1d2 + n2d1)/d1d2
(define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))
    )
)

; n1/d1 - n2/d2 = (n1d2 - n2d1)/d1d2
(define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))
    )
)

; n1/d1 * n2/d2 = n1n2/d1d2
(define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))
    )
)

; (n1/d1) / (n2/d2) = n1d2/n2d1
(define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (numer y) (denom x))
    )
)

; n1/d1 = n2/d2, n1d2 = n2d1
; or use built-in equal?
(define (equal-rat? x y)
    (= (* (numer x) (denom y))
       (* (numer y) (denom x)))
)

; output
(define (print-rat x)
    (display (numer x))
    (display "/")
    (display (denom x))
    (newline)
)

(define x (make-rat 1 2))
(define y (make-rat 1 3))
(print-rat (add-rat x y))
(print-rat (sub-rat x y))
(print-rat (mul-rat x y))
(print-rat (div-rat x y))
(equal-rat? x y)
(equal-rat? (add-rat x y) (make-rat 5 6))
(print-rat (add-rat x x))

; abstraction levels
; ---------top---------
; procedure that use rational numbers
; add-rat/sub-rat/mul-rat/...
; make-rat/numer/denom
; cons/car/cdr
; ---------down---------