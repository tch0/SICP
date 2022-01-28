#lang sicp

; vector
(define (make-vect a b) (cons a b))
(define (xcor-vect v) (car v))
(define (ycor-vect v) (cdr v))
(define (add-vect v1 v2)
    (make-vect (+ (xcor-vect v1) (xcor-vect v2)) 
               (+ (ycor-vect v1) (ycor-vect v2)))
)
(define (sub-vect v1 v2)
    (make-vect (- (xcor-vect v1) (xcor-vect v2)) 
               (- (ycor-vect v1) (ycor-vect v2)))
)
(define (scale-vect v scale)
    (make-vect (* scale (xcor-vect v))
               (* scale (ycor-vect v)))
)

; test
(define v (make-vect 10 20))
(define v2 (make-vect 5 10))
(xcor-vect v)
(ycor-vect v)
(add-vect v v2)
(sub-vect v v2)
(scale-vect v 3)