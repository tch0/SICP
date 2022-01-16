#lang sicp

; smooth a function: somooth(f(x)) = [f(x+dx) + f(x) + f(x-dx)]/3
(define dx 0.00001)
(define (smooth f)
    (lambda (x)
        (/ (+ (f (+ x dx))
              (f x)
              (f (- x dx)))
            3.0)
    )
)

(define (repeated f n)
    (if (= n 1)
        f
        (lambda (x)
            (let ((fs (repeated f (- n 1))))
                (fs (f x))
            )
        )
    )
)

(define (smooth-n-times f n)
    ((repeated smooth n) f)
)

(define (square x) (* x x))
((smooth square) 5)
(((repeated smooth 10) square) 5) ; smooth 10 times
((smooth-n-times square 10) 5) 
