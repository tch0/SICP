#lang sicp

; a + |b|
; high order function
(define (a-plus-abs-b a b)
    ((if (> b 0) + -) a b)
)