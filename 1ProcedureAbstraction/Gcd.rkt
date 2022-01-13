#lang sicp

(define (mygcd a b)
    (if (= b 0)
        a
        (mygcd b (remainder a b)))
)

(mygcd 21 81)
(gcd 21 81)