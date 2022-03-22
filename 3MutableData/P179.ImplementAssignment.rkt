#lang sicp

; implementation of pair
(define (cons x y)
    (define (set-x! v) (set! x v))
    (define (set-y! v) (set! y v))
    (define (dispatch m)
        (cond ((eq? m 'car) x)
              ((eq? m 'cdr) y)
              ((eq? m 'set-car!) set-x!)
              ((eq? m 'set-cdr!) set-y!)
              (else (error "Unkown request -- in cons/dispatch, " m))
        )
    )
    dispatch
)
(define (car z) (z 'car))
(define (cdr z) (z 'cdr))
(define (set-car! z value) ((z 'set-car!) value))
(define (set-cdr! z value) ((z 'set-cdr!) value))

; test
(define x (cons 1 2))
(car x)
(cdr x)
(set-car! x 10)
(set-cdr! x 20)
(car x)
(cdr x)