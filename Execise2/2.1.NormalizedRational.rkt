#lang sicp

; normalized rational number, if negative, let numerator be negative
(define (make-rat n d)
    (let ((g (gcd n d)))
        (if (< d 0)
            (cons (- (/ n g)) (- (/ d g)))
            (cons (/ n g) (/ d g))
        )
    )
)

(make-rat -10 -5)