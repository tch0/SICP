#lang sicp

; auxiliary procedures
(define (memo-proc proc)
    (let ((already-run? false)
          (result false))
        (lambda ()
            (if (not already-run?)
                (begin (set! result (proc))
                       (set! already-run? true)
                       result
                )
                result
            )
        )
    )
)

; implementation of delay and force
; delay should be a special form, arg should not be evaluated, so it's just a implementation demo of delay that can not run.
(define (delay arg)
    (lambda () (memo-proc arg))
)

; only evaluate the expression in the first time
(define (force delayed-object) (delayed-object))