#lang sicp

(define f
    (let ((called #f))
        (lambda (num)
            (if called
                0
                (begin (set! called #t) num)
            )
        )
    )
)

(+ (f 0) (f 1)) ; 0
; (+ (f 1) (f 0)) ; 1