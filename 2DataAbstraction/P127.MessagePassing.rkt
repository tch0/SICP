#lang sicp

; auxiliary functions
(define (square x) (* x x))

; message passing style

; implement data as a function, accept one argument as the operation that we want to apply for this data.
(define (make-from-real-imag x y)
    (define (dispatch op)
        (cond ((eq? op 'real-part) x)
              ((eq? op 'imag-part) y)
              ((eq? op 'magnitude) (sqrt (+ (square x) (square y))))
              ((eq? op 'angle) (atan y x))
              (else (error "unkown op -- in function make-from-real-image/dispatch, " op))
        )
    )
    dispatch
)

(define (apply-generic op arg) (arg op))

; Ex 2.75
(define (make-from-mag-ang r a)
    (define (dispatch op)
        (cond ((eq? op 'real-part) (* r (cos a)))
              ((eq? op 'imag-part) (* r (sin a)))
              ((eq? op 'magnitude) r)
              ((eq? op 'angle) a)
              (else (error "unkown op -- in function make-from-mag-ang/dispatch, " op))
        )
    )
    dispatch
)