#lang sicp

; from Exercise3/3.3.AccountWithPassword.rkt
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

; shared account
(define (make-joint account exist-password new-password)
    (define (dispatch password message)
        (if (eq? password new-password)
            (account exist-password message) ; input new password
            (account password message) ; input existed password
        )
    )
    dispatch
)



; test
(define nephren-acc (make-account 100 'nephren))
((nephren-acc 'nephren 'withdraw) 20)
((nephren-acc 'nephren 'withdraw) 40)
((nephren-acc 'nephren 'withdraw) 45)
((nephren-acc 'nephren 'deposit) 100)
((nephren-acc 'other-password 'withdraw) 100)

(newline)
(define chtholly-acc (make-joint nephren-acc 'nephren 'chtholly))
((chtholly-acc 'chtholly 'withdraw) 50)
((chtholly-acc 'nephren 'deposit) 10)
((chtholly-acc 'ithea 'withdraw) 100) ; wrong password as intended

(newline)
(define ithea-acc (make-joint chtholly-acc 'chtholly 'ithea))
((ithea-acc 'ithea 'deposit) 100)
((ithea-acc 'chtholly 'deposit) 100)
((ithea-acc 'nephren 'deposit) 100)