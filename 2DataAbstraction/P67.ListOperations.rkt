#lang sicp

; nil
; visit by index
(define (list-ref items n)
    (if (= n 0)
        (car items)
        (list-ref (cdr items) (- n 1))
    )
)

; length of list
(define (length items)
    (if (null? items)
        0
        (+ 1 (length (cdr items)))
    )
)
; iteration
(define (length2 items)
    (define (length-iter count items)
        (if (null? items)
            count
            (length-iter (+ count 1) (cdr items))
        )
    )
    (length-iter 0 items)
)

; append element to tail of list
(define (append list1 list2)
    (if (null? list1)
        list2
        (cons (car list1) (append (cdr list1) list2))
    )
)

; equivalent form of list
(list 1 2 3 4)
'(1 2 3 4)
(cons 1 (cons 2 (cons 3 (cons 4 nil))))

; empty list
nil
'()
(list)
(null? nil) ; #t

; test
(define l '(1 2 3 4))
(list-ref l 0)
(length l)
(length2 l)
(append '(1 2) '(3 4))