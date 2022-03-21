#lang sicp

(define (make-accumulator value)
    (define (add num)
        (begin (set! value (+ value num))
               value
        )
    )
    add
)

(define acc (make-accumulator 10))
(acc 1)
(acc 10)