#lang sicp

; using scheme built-in number instead of (scheme-number x)
(define (attach-tag type-tag contents)
    (if (number? contents)
        contents
        (cons type-tag contents)
    )
)
(define (type-tag datum)
    (cond ((number? datum) 'scheme-number)
          ((pair? datum) (car datum))
          (else (error "Bad tagged datum -- in function type-tag, " datum))
    )
)
(define (contents datum)
    (cond ((number? datum) datum)
          ((pair? datum) (cdr datum))
          (else (error "Bad tagged datum -- in function contents, " datum))
    )
)

; test
(type-tag (attach-tag 'scheme-number 1))
(contents (attach-tag 'scheme-number 1))
(attach-tag 'scheme-number 1)