#lang sicp

; reset random generator

; LCG: generate simple pseudo random number
; Nj+1 = (A*Nj + B) Mod M, A = 1103515245, B=12345, M = 2^31
(define (rand-update x)
    (remainder (+ (* 1103515245 x) 12345) #x7FFFFFFF)
)
(define random-init 0)
(define rand
    (let ((x random-init))
        (lambda (request)
            (cond ((eq? request 'generate) (set! x (rand-update x)) x)
                  ((eq? request 'reset) (lambda (new-value) (set! x new-value)))
                  (else (error "Unknown request -- in rand, " request))
            )
        )
    )
)

; test
(rand 'generate)
(rand 'generate)
(rand 'generate)
(rand 'generate)
(rand 'generate)
((rand 'reset) 0)
(rand 'generate)
(rand 'generate)
(rand 'generate)
((rand 'reset) 100)
(rand 'generate)