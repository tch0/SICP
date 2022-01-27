#lang sicp

; reverse a list
; recursion: low efficiency because of append
(define (reverse items)
    (if (null? items)
        '()
        (append (reverse (cdr items)) (list (car items)))
    )
)

; iteration
(define (reverse2 items)
    (define (iter items result)
        (if (null? items)
            result
            (iter (cdr items) (cons (car items) result))
        )
    )
    (iter items '())
)

(reverse '(1 2 3 4))
(reverse2 '(1 2 3 4))
(reverse '())
(reverse2 '())