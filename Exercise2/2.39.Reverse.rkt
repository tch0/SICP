#lang sicp

; fold from Execise2/2.38.FoldLeft.rkt
(define (fold-right op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (fold-right op initial (cdr sequence)))
    )
)

(define (fold-left op initial sequence)
    (if (null? sequence)
        initial
        (fold-left op (op initial (car sequence)) (cdr sequence))
    )
)
; ====================================================================================

; use fold-left and fold-right implement reverse
; reverse-r uses append, will increase the time complexity by one degree of N
(define (reverse-r sequence) 
    (fold-right (lambda (elem result) (append result (list elem))) nil sequence)
)

(define (reverse-r2 sequence)
    (fold-right (lambda (elem result) (fold-right cons (list elem) result)) nil sequence)
)

(define (reverse-l sequence)
    (fold-left (lambda (result elem) (cons elem result)) nil sequence)
)


; test
(reverse-r (list 1 2 3 4))
(reverse-r2 (list 1 2 3 4))
(reverse-l (list 1 2 3 4))