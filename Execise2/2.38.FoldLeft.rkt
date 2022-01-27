#lang sicp

; accumulate, aka fold-right
(define (fold-right op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (fold-right op initial (cdr sequence)))
    )
)
; ====================================================================================

; fold left, from left to right
; iteration
(define (fold-left op initial sequence)
    (define (iter result rest)
        (if (null? rest)
            result
            (iter (op result (car rest)) (cdr rest))
        )
    )
    (iter initial sequence)
)

; another iteration
(define (fold-left2 op initial sequence)
    (if (null? sequence)
        initial
        (fold-left2 op (op initial (car sequence)) (cdr sequence))
    )
)

; test
(fold-right - 5 '(1 2 3 4)) ; (1 - (2 - (3 - (4 - 5)))) = 3
(fold-left - 5 '(1 2 3 4)) ; ((((5 - 1) - 2) - 3) - 4) = -5
(fold-left2 - 5 '(1 2 3 4))

; examples
(fold-right / 1 '(1 2 3)) ; 3/2
(fold-left / 1 '(1 2 3)) ; 1/6
(fold-right list nil '(1 2 3)) ; (1 (2 (3 ())))
(fold-left list nil '(1 2 3)) ; (((() 1) 2) 3)