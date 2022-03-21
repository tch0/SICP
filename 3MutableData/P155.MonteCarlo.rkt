#lang sicp

(define random-init 0)
; LCG: generate simple pseudo random number
; Nj+1 = (A*Nj + B) Mod M, A = 1103515245, B=12345, M = 2^31
(define (rand-update x)
    (remainder (+ (* 1103515245 x) 12345) #x7FFFFFFF)
)
(define rand
    (let ((x random-init))
        (lambda ()
            (set! x (rand-update x))
            x
        )
    )
)

; Monte Carlo simulation, calculate 6/PI^2
; the probability that getting two integer randomly, they do not have a common divisor
(define (estimate-pi trials)
    (sqrt (/ 6 (monte-carlo trials cesaro-test)))
)

(define (cesaro-test)
    (= (gcd (rand) (rand)) 1)
)

(define (monte-carlo trials experiment)
    (define (iter trials-remaining trials-passed)
        (cond ((= trials-remaining 0) (/ trials-passed trials))
              ((experiment) (iter (- trials-remaining 1) (+ trials-passed 1)))
              (else (iter (- trials-remaining 1) trials-passed))
        )
    )
    (iter trials 0)
)

; test
(estimate-pi 100)
(estimate-pi 1000)
(estimate-pi 10000)
(estimate-pi 100000)
(estimate-pi 1000000)