#lang sicp

; use an auxiliary data structure to save pairs already visited
(define (count-pairs x)
    (define visited nil)
    (define (helper x)
        (if (or (not (pair? x)) (memq x visited))
            0
            (begin (set! visited (cons x visited))
                   (+ (helper (car x))
                      (helper (cdr x))
                      1)
            )
        )
    )
    (helper x)
)

; test
(count-pairs (list 'a 'b 'c 'd))
(define x (cons 'a 'b))
(count-pairs (list x x (cons x x)))