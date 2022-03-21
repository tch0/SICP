#lang sicp

(define (make-account balance account-password)
    (define (withdraw amount)
        (if (>= balance amount)
            (begin (set! balance (- balance amount))
                   balance
            )
            "Insufficient funds"
        )
    )
    (define (deposit amount)
        (begin (set! balance (+ balance amount))
               balance
        )
    )
    (define (dispatch input-password m)
        (cond ((not (eq? input-password account-password)) (lambda (arg) "Incorrect password"))
              ((eq? m 'withdraw) withdraw)
              ((eq? m 'deposit) deposit)
              (else (error "Unkown request -- in make-account/dispatch" m))
        )
    )
    dispatch
)

; test
(define acc (make-account 100 'nephren))
((acc 'nephren 'withdraw) 20)
((acc 'nephren 'withdraw) 40)
((acc 'nephren 'withdraw) 45)
((acc 'nephren 'deposit) 100)
((acc 'other-password 'withdraw) 100)