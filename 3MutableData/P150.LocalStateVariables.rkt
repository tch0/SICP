#lang sicp

; local varaibles and assignment

; assignment : set!
(define balance 100)
(define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance
        )
        "Insufficient funds"
    )
)

(withdraw 20)
(withdraw 40)
(withdraw 45)

; new withdraw, define balance as a local state variable, only withdraw can modifiy it
(define new-withdraw
    (let ((balance 100)) ; local state variable
        (lambda (amount)
            (if (>= balance amount)
                (begin (set! balance (- balance amount))
                       balance
                )
                "Insufficient funds"
            )
        )
    )
)

(new-withdraw 20)
(new-withdraw 40)
(new-withdraw 45)

; another withdraw implementation
(define (make-withdraw balance)
    (lambda (amount)
        (if (>= balance amount)
            (begin (set! balance (- balance amount))
                   balance
            )
            "Insufficient funds"
        )
    )
)
; W1 W2 are completely isolate object
(define W1 (make-withdraw 100))
(define W2 (make-withdraw 100))


(W1 20)
(W1 40)
(W1 45)
(W2 80)

; account object
(define (make-account balance)
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
    (define (dispatch m)
        (cond ((eq? m 'withdraw) withdraw)
              ((eq? m 'deposit) deposit)
              (else (error "Unkown request -- in make-account" m))
        )
    )
    dispatch
)

(define acc (make-account 100))
((acc 'withdraw) 20)
((acc 'withdraw) 40)
((acc 'withdraw) 45)
((acc 'deposit) 100)