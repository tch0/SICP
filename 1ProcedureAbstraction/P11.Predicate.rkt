#lang sicp

; true: #t (everything except #f), false: #f

; predicate: cond, if
(define (abs x)
    (cond ((> x 0) x)
          (else (- x))
    )
)

(define (abs2 x)
    (if (> x 0)
        x
        (- x)
    )
)

(abs -1)
(abs2 -1)

; compand logic operator: and, or, not
; all special procedure, do not evaluate every subexpression.
(and #t false)
(or #f true)
(not #f)

; relationship operator: > < = >= <=
(> 3 4)
(= 2 2)
(<= 10 10)
