#lang sicp

; 带点尾部记法实现可变参数
; dotted-tial notation
; recursion
(define (same-parity first . items)
    (define (filter items valid?)
        (cond ((null? items) '())
              ((valid? (car items)) (cons (car items) (filter (cdr items) valid?)))
              (else (filter (cdr items) valid?))
        )
    )
    (let ((valid? (if (odd? first) odd? even?)))
        (cons first (filter items valid?))
    )
)

; iteration
; do not use append, append is expensive
(define (same-parity2 first . items)
    ; filter, reuslt is in reverse order
    (define (filter-reverse items valid? result)
        (cond ((null? items) result)
              ((valid? (car items)) (filter-reverse (cdr items) valid? (cons (car items) result)))
              (else (filter-reverse (cdr items) valid? result))
        )
    )
    (let ((valid? (if (odd? first) odd? even?)))
        (cons first (reverse (filter-reverse items valid? '())))
    )
)

(same-parity 1 2 3 4 5 6 11)
(same-parity2 1 2 3 4 5 6 11)
(same-parity2 2 3 4 13 13 1 40)