#lang sicp

; map every element of the list
; library function: map
(define (map proc items)
    (if (null? items)
        nil
        (cons (proc (car items))
          (map proc (cdr items)))
    )
)

(map (lambda (x) (* 2 x)) '(1 2 3))