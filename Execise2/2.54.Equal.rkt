#lang sicp

; define equal?
(define (equal? a b)
    (cond ((and (null? a) (null? b)) #t)
          ((or (null? a) (null? b)) #f)
          ((and (pair? a) (pair? b)) (and (equal? (car a) (car b)) (equal? (cdr a) (cdr b))))
          (else (eq? a b))
    )
)

; another
(define (equal2? a b)
    (cond ((and (symbol? a) (symbol? b)) (eq? a b))
          ((and (pair? a) (pair? b)) (and (equal2? (car a) (car b)) (equal2? (cdr a) (cdr b))))
          (else #f)
    )
)

; test
(equal? '(a b (c (d e))) (list 'a 'b '(c (d e))))
(equal? '(a b (c (d e))) (list 'a 'b '(c (d e f))))
(equal? (cons 'a 'b) (cons 'a 'b))
(equal2? (cons 'a 'b) (cons 'a 'b))