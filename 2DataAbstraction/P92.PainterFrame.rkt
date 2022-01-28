#lang sicp
(#%require sicp-pict)

; use built-in procedures: make-vect, vector-add, vector-scale, vector-xcor, vector-ycor

; frame of painter
(define (make-frame origin edge1 edge2)
    (list origin edge1 edge2)
)
(define (origin-frame frame) (car frame))
(define (edge1-frame frame) (cadr frame))
(define (edge2-frame frame) (caddr frame))

(define (frame-coord-map frame)
    (lambda (v)
        (vector-add (origin-frame frame)
                    (vector-add (vector-scale (vector-xcor v)
                                              (edge1-frame frame))
                                (vector-scale (vector-ycor v)
                                              (edge2-frame frame)))
        )
    )
)

; test
(define a-frame (make-frame (make-vect 1 2) (make-vect 0 0) (make-vect 0 0)))
((frame-coord-map a-frame) (make-vect 0 0))
(origin-frame a-frame)