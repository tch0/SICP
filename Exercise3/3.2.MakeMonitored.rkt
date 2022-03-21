#lang sicp

; like a decorator, but decorate a function
(define (make-monitored func)
    (let ((count 0))
        (lambda (arg)
            (cond ((eq? arg 'how-many-calls?) count)
                  ((eq? arg 'reset-count) (set! count 0))
                  (else (set! count (+ count 1)) (func arg))
            )
        )
    )
)

(define s (make-monitored sqrt))
(s 'how-many-calls?)
(s 100)
(s 'how-many-calls?)
(s 'reset-count)
(s 'how-many-calls?)