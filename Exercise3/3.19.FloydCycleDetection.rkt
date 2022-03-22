#lang sicp

; floyd cycle detection algorithm
(define (contain-cycle? x)
    (define (safe-cdr x)
        (if (pair? x)
            (cdr x)
            nil
        )
    )
    (define (iter a b)
        (cond ((not (pair? a)) #f)
              ((not (pair? b)) #f)
              ((eq? a b) #t)
              ((eq? a (safe-cdr b)) #t)
              (else (iter (safe-cdr a) (safe-cdr (safe-cdr b))))
        )
    )
    (iter (safe-cdr x) (safe-cdr (safe-cdr x)))
)

; test
(contain-cycle? (list 'a 'b 'c 'd))
(define loop (list 'a 'b 'c))
(set-cdr! (cddr loop) loop)
(contain-cycle? loop)