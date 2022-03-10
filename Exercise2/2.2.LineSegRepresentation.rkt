#lang sicp

; point
(define (make-point x y) (cons x y))
(define (x-point p) (car p))
(define (y-point p) (cdr p))

; line segment
(define (make-segment start end) (cons start end))
(define (start-segment seg) (car seg))
(define (end-segment seg) (cdr seg))

; output
(define (print-point p) 
    (display "(")
    (display (x-point p))
    (display ", ")
    (display (y-point p))
    (display ")")
    (newline)
)

; mid point of segment
(define (average a b) (/ (+ a b) 2.0))
(define (midpopint-segment seg)
    (let ((start (start-segment seg))
          (end (end-segment seg)))
        (make-point (average (x-point start) (x-point end))
                    (average (y-point start) (y-point end))
        )
    )
)

; test
(define startp (make-point 1.0 1.0))
(define endp (make-point 2.0 3.0))
(define seg (make-segment startp endp))
(print-point (midpopint-segment seg))