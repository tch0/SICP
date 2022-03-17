#lang sicp


; iteration
(do ((vec (make-vector 5)) ; (<variable1> <init> <step>)
     (i 0 (+ i 1)))
    ((= i 5) vec) ; (<test> <expression> ...)
    (vector-set! vec i (* i i)) ; set value of index i to i*i
)
; result: #(0 1 4 9 16)

; named let
(let loop ((a 10))
    (if (> a 0)
        (begin (display a) (display " ") (loop (- a 1)))
    )
)
; result: 10 9 8 7 6 5 4 3 2 1