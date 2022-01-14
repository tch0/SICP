#lang sicp

; exchange specificed money to combination of 0.5/0.25 dollar and 10/5/1 cents, how many methods?
(define (count-change amount)
    (define (cc amount kind-of-coins)
        (cond ((= amount 0) 1)
              ((or (< amount 0) (= kind-of-coins 0)) 0)
              (else (+ (cc amount (- kind-of-coins 1))
                       (cc (- amount (first-denomination kind-of-coins)) kind-of-coins))
              )
        )
    )
    (define (first-denomination kind-of-coins)
        (cond ((= kind-of-coins 1) 1)
              ((= kind-of-coins 2) 5)
              ((= kind-of-coins 3) 10)
              ((= kind-of-coins 4) 25)
              ((= kind-of-coins 5) 50))
    )
    (cc amount 5)
)

; one dollar
(count-change 100) ; 292