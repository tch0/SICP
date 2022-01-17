#lang sicp

; only use procedure implement pair (cons & car & mycdr)
(define (mycons x y)
    (define (dispatch m)
        (cond ((= m 0) x)
              ((= m 1) y)
              (else (error "Argument not 0 or 1 -- in mycons" m))
        )
    )
    dispatch
)
(define (mycar z) (z 0))
(define (mycdr z) (z 1))

(define p (mycons 1 2))
(mycar p)
(mycdr p)