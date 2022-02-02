#lang sicp

; example: symbolic derivation

; auxiliary functions
(define (=number? exp num)
    (and (number? exp) (= exp num))
)
(define (variable? e) (symbol? e))
(define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2))
)

; 和式
(define (sum? e) (and (pair? e) (eq? (car e) '+)))        ; e是和式吗？
(define (addend e) (cadr e))        ; e的被加数
(define (augend e) (caddr e))       ; e的加数
(define (make-sum a1 a2)
    (cond  ((=number? a1 0) a2)
           ((=number? a2 0) a1)
           ((and (number? a1) (number? a2)) (+ a1 a2))
           (else (list '+ a1 a2))
    )
)       ; 构建a1和a2的和式

; 乘式
(define (product? e) (and (pair? e) (eq? (car e) '*)))     ; e是乘式吗？
(define (multiplier e) (cadr e))    ; e的被乘数
(define (multiplicand e) (caddr e)) ; e的乘数
(define (make-product m1 m2)
    (cond ((or (=number? m1 0) (=number? m2 0)) 0)
          ((=number? m1 1) m2)
          ((=number? m2 1) m1)
          ((and (number? m1) (number? m2)) (* m1 m2))
          (else (list '* m1 m2))
    )
)       ; 构建起m1和m2的乘式

; d exp / d var
; derivation rules:
;   dc/dx = 0, c is a constant
;   dx/dx = 1
;   d(u+v)/dx = du/dx + dv/dx
;   d(uv)/dx = u(dv/dx) + v(du/dx)
(define (derivation exp var)
    (cond ((number? exp) 0)
          ((variable? exp) (if (same-variable? exp var) 1 0))
          ((sum? exp) (make-sum (derivation (addend exp) var)
                                (derivation (augend exp) var)))
          ((product? exp) (make-sum (make-product (multiplier exp)
                                                  (derivation (multiplicand exp) var))
                                    (make-product (multiplicand exp)
                                                  (derivation (multiplier exp) var))))
          (else (error "unkown expression type -- derivation" exp))
    )
)

; test
; d(xy) / dx = 0*x + 1*y = y
(derivation '(* x y) 'x)
; d(3+x) / dx = 1
(derivation '(+ 3 x) 'x)
; d(xy * (3+x))/dx = 2xy + 3y
(derivation '(* (* x y) (+ x 3)) 'x)