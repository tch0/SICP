#lang sicp

; refactoring of P26.ExchangeMoney.rkt
; values of coins passed as a list
; cc(amount, kind) = 1, amount = 0
;                  = cc(amount, kind-1) + cc(amount-first-denomination, kind)
(define (count-change amount coin-values)
    (define (cc amount coin-values)
        (cond ((= amount 0) 1)
              ((or (< amount 0) (no-more? coin-values)) 0)
              (else (+ (cc amount (except-first-denomination coin-values))
                       (cc (- amount (first-denomination coin-values)) coin-values)))
        )
    )
    (define (except-first-denomination coin-values)
        (cdr coin-values)
    )
    (define (first-denomination coin-values)
        (car coin-values)
    )
    (define (no-more? coin-values)
        (null? coin-values)
    )
    (cc amount coin-values)
)

(define us-coins (list 50 25 10 5 1))
(define uk-coins (list 100 50 20 10 5 2 1 0.5))
(define us-coins2 (list 1 5 10 25 50))
(count-change 100 us-coins) ; 292
(count-change 100 us-coins2) ; 292
(count-change 100 uk-coins) ; 104561, wow!