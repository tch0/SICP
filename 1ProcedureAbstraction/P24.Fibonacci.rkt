#lang sicp

; recursion
(define (fibonacci n)
    (cond ((= n 0) 0)
          ((= n 1) 1)
          (else (+ (fibonacci (- n 1))
                   (fibonacci (- n 2))))
    )
)

(fibonacci 10)

; linear iteration
(define (fibonacci2 n)
    (define (fib-iter a b count)
        (if (= count 0)
            b
            (fib-iter (+ a b) a (- count 1)))
    )
    (fib-iter 1 0 n)
)

(fibonacci2 10) ; 55
(fibonacci2 1000)