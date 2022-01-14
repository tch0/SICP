#lang sicp

; inner definition
(define (sqrt x)
    (define (sqrt-iter guess change x)
        (define new-guess (improve guess x))
        (if (good-enough? guess change)
            guess
            (sqrt-iter new-guess
                       (abs (- new-guess guess))
                       x)
        )
    )
    (define (improve guess x)
        (average (/ x guess) guess)
    )
    (define (average x y)
        (/ (+ x y) 2.0)
    )
    (define (good-enough? guess change)
        (< (/ change guess) 0.0001)
    )
    (sqrt-iter 1.0 1.0 x)
)

(define (square x)
    (* x x)
)

(sqrt (square 2.0))
(sqrt (square 123874.45321))