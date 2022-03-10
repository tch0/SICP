#lang sicp

; reverse a list
(define (reverse items)
    (define (iter items result)
        (if (null? items)
            result
            (iter (cdr items) (cons (car items) result))
        )
    )
    (iter items nil)
)

; deep reverse a tree
; http://community.schemewiki.org/?sicp-ex-2.27
; maybe need some fault tolerance
(define (deep-reverse tree)
    (define (iter items result)
        (if (null? items)
            result
            (iter (cdr items)
                  (cons (if (list? (car items)) ; list? is better than pair?, because the element of list could be pair.
                            (deep-reverse (car items)) ; not leave
                            (car items)) ; leave
                        result)
            )
        )
    )
    (iter tree nil)
)

; use reverse implement deep-reverse, could be extrmely concise
(define (deep-reverse2 tree)
    (if (list? tree) ; list? is way better than pair?, think about test case 2.
        (reverse (map deep-reverse2 tree))
        tree
    )
)

; since append is expensive, do not consider to use append.

; test
(reverse (list (list 1 2) (list 3 4)))
(deep-reverse (list (list 1 2) (list 3 4)))
(deep-reverse (list (cons 1 2) (cons 3 4)))
(deep-reverse2 (list (list 1 2) (list 3 4)))
(deep-reverse2 (list (cons 1 2) (cons 3 4)))