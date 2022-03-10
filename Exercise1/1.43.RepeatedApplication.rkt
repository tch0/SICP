#lang sicp

(define (repeated f n)
    (if (= n 1)
        f
        (lambda (x)
            (let ((fs (repeated f (- n 1))))
                (f (fs x)))
        )
    )
)

(define (square x) (* x x))

((repeated inc 10) 10)
((repeated square 2) 5)