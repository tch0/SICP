#lang sicp

; last pair of list (last-element nil)
; items should not be nil
(define (last-pair items)
    (if (null? (cdr items))
        items
        (last-pair (cdr items))
    )
)

; test
(last-pair '(1 2 3 4 5))
(last-pair (list 1 2 3))