#lang sicp

; auxiliary procedures
; test-and-set! and clear! must be atomic operations
(define (test-and-set! cell)
    (if (car cell)
        true
        (begin (set-car! cell true) false)
    )
)
(define (clear! cell) (set-car! cell false))

; mutex
(define (make-mutex)
    (let ((cell (list false)))
        (define (the-mutex m)
            (cond ((eq? m 'acquire) (if (test-and-set! cell) (the-mutex 'acquire))) ; retry
                  ((eq? m 'release) (clear! cell))
            )
        )
        the-mutex
    )
)

; serializer
(define (make-serializer)
    (let ((mutex (make-mutex)))
        (lambda (p)
            (define (serialized-p . args)
                (mutex 'acquire)
                (let ((val (apply p args)))
                    (mutex 'release)
                    val
                )
            )
            serialized-p
        )
    )
)