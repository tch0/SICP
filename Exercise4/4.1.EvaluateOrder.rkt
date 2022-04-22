#lang sicp

; abstraction of operands, from procedrue (operands exp)
(define (no-operands? exps) nil)
(define (first-operand exps) nil)
(define (rest-operands exps) nil)

; left to right
; evaluate operands of a combinator
(define (list-of-values exps env)
    (if (no-operands? exps)
        '()
        (let ((left (eval (first-operand exps) env)))
            (cons left (list-of-values (rest-operands exps) env))
        )
    )
)


; right to left
(define (list-of-values2 exps env)
    (if (no-operands? exps)
        '()
        (let ((right (list-of-values (rest-operands exps) env)))
            (cons (eval (first-operand exps) env) right)
        )
    )
)