#lang sicp

; generate all subsets of a set
(define (subsets s)
    (if (null? s)
        (list nil)
        (let ((rest (subsets (cdr s))))
            (append rest (map (lambda (x) (append (list (car s)) x)) rest))
        )
    )
)

(subsets (list 1 2 3))