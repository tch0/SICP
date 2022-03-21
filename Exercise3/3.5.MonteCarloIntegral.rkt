#lang sicp

; monte carlo procedure
(define (monte-carlo trials experiment)
    (define (iter trials-remaining trials-passed)
        (cond ((= trials-remaining 0) (/ trials-passed trials))
              ((experiment) (iter (- trials-remaining 1) (+ trials-passed 1)))
              (else (iter (- trials-remaining 1) trials-passed))
        )
    )
    (iter trials 0)
)

; generate a random real number between low and hogh
(define (random-in-range low high)
    (let ((range (- high low)))
        (+ low (random range))
    )
)

; the area of predicate P surrounded
(define (estimate-integral P x1 x2 y1 y2 trials)
    (* (- y2 y1)
       (- x2 x1)
       (monte-carlo trials (lambda () (P (random-in-range x1 x2) (random-in-range y1 y2))))
    )
)

(define (estimate-pi trials)
    (estimate-integral (lambda (x y) (<= (+ (* x x) (* y y)) 1))
                       -1.0
                       1.0
                       -1.0
                       1.0
                       trials
    )
)

; test
(estimate-pi 10)
(estimate-pi 100)
(estimate-pi 1000)
(estimate-pi 10000)
(estimate-pi 100000)
(estimate-pi 1000000)