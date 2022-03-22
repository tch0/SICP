#lang sicp

; car and cdr share one address
(define x (list 'a 'b))
(define z1 (cons x x))
(eq? (car z1) (cdr z1))
(set-car! (car z1) 'wow)
z1

(define z2 (cons (list 'a 'b) (list 'a 'b)))
(eq? (car z2) (cdr z2))
(set-car! (car z2) 'wow)
z2
