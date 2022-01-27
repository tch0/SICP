#lang sicp

; implement for-each

(define (my-for-each proc items)
    (if (null? items)
        #t
        (and (proc (car items)) (my-for-each proc (cdr items)))
    )
)

(define (my-for-each2 proc items)
    (map proc items)
    #t
)

(define print (lambda (x) (display x) (newline)))
(for-each print '(1 2 3))
(my-for-each print '(1 2 3))
(my-for-each2 print '(1 2 3))