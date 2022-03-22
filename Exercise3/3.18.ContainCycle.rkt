#lang sicp

; Does a list contain a cycle?
(define (contain-cycle? x)
    (define visited nil)
    (define (iter x)
        (cond ((not (pair? x)) #f)
              ((memq x visited) #t)
              (else (begin (set! visited (cons x visited))
                           (or (iter (car x)) (iter (cdr x)))))
        )
    )
    (iter x)
)

; test
(contain-cycle? (list 'a 'b 'c 'd))
(define loop (list 'a 'b 'c))
(set-cdr! (cddr loop) loop)
(contain-cycle? loop)
(contain-cycle? (cons loop 1))