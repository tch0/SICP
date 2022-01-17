#lang sicp

; from 2.2
; point
(define (make-point x y) (cons x y))
(define (x-point p) (car p))
(define (y-point p) (cdr p))
; output point
(define (print-point p)
    (display "(")
    (display (x-point p))
    (display ", ")
    (display (y-point p))
    (display ")")
)

; rectangle: use one point and width and length
(define (make-rectangle left-bottom-point length width)
    (cons left-bottom-point (cons length width))
)
(define (left rect) (x-point (car rect)))
(define (right rect) (+ (left rect) (length rect)))
(define (bottom rect) (y-point (car rect)))
(define (top rect) (+ (bottom rect) (width rect)))
(define (length rect) (car (cdr rect)))
(define (width rect) (cdr (cdr rect)))

; perimeter, area
(define (rect-perimeter rect)
    (* 2 (+ (length rect) (width rect)))
)
(define (rect-area rect)
    (* (length rect) (width rect))
)

; output
(define (print-rect rect)
    (display "rectangle: [left-bottom point: ")
    (print-point (car rect))
    (display ", length: ")
    (display (length rect))
    (display ", width: ")
    (display (width rect))
    (display "]")
    (newline)
)

; test
(define r (make-rectangle (make-point 1 1) 2 3))
(rect-perimeter r)
(rect-area r)
(print-rect r)