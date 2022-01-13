#lang sicp
(define (min x y)
    (if (< x y)
        x
        y
    )
)

(define (max2sum x y z)
    (- (+ x y z)
       (min x (min y z))
    )
)

(max2sum 10 -2 100)
