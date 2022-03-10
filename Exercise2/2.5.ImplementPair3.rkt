#lang sicp

; implement pair
(define (mycons a b)
    (* (expt 2 a) (expt 3 b))
)

(define (mycar z)
    (if (= 0 (remainder z 2))
        (+ 1 (mycar (/ z 2)))
        0)
)

(define (mycdr z)
    (if (= 0 (remainder z 3))
        (+ 1 (mycdr (/ z 3)))
        0)
)

; test
(define p (mycons 10 202))
(mycar p)
(mycdr p)