#lang sicp
(#%require sicp-pict)

; do not need the vector definition in Ex 2.46
; segment
(define (make-segment start end)
    (cons start end)
)
(define (start-sgement seg) (car seg))
(define (end-segment seg) (cdr seg))

; test : none