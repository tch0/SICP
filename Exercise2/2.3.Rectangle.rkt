#lang sicp

; rectangle, use left, right, bottom, up
(define (make-rectangle left right bottom top)
    (let ((l (min left right))
          (r (max left right))
          (b (min bottom top))
          (t (max bottom top)))
        (cons (cons l r) (cons b t))
    )
)
(define (left rect) (car (car rect)))
(define (right rect) (cdr (car rect)))
(define (bottom rect) (car (cdr rect)))
(define (top rect) (cdr (cdr rect)))
(define (length rect) (- (right rect) (left rect)))
(define (width rect) (- (top rect) (bottom rect)))

; perimeter, area
(define (rect-perimeter rect)
    (* 2 (+ (length rect) (width rect)))
)
(define (rect-area rect)
    (* (length rect) (width rect))
)

; output
(define (print-rect rect)
    (display "rectangle: [left: ")
    (display (left rect))
    (display ", right: ")
    (display (right rect))
    (display ", bottom: ")
    (display (bottom rect))
    (display ", top: ")
    (display (top rect))
    (display "]")
    (newline)
)

; test
(define r (make-rectangle 1 3 1 4))
(rect-perimeter r)
(rect-area r)
(print-rect r)