#lang sicp

; extend symbolic derivation to support exponentiation

; ==================================================================================
; from 2DataAbstraction/P100.SymbolicDerivation.rkt

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
; ==================================================================================

; 指数形式，a^b，当前只支持幂函数而不支持指数函数。
; exponentiation
; 0^0 : no meaning
(define (make-exponentiation base exponent)
    (cond ((and (=number? base 0) (=number? exponent 0)) (error "0^0 has no meaning." base exponent))
          ((=number? base 0) 0)
          ((=number? exponent 0) 1)
          ((=number? exponent 1) base)
          ((and (number? base) (number? exponent)) (expt base exponent))
          (else (list 'exp base exponent))
    )
)
(define (exponentiation? e)
    (and (pair? e) (eq? (car e) 'exp))
)
(define (base e) (cadr e))
(define (exponent e) (caddr e))

; d exp / d var
; derivation rules:
;   dc/dx = 0, c is a constant
;   dx/dx = 1
;   d(u+v)/dx = du/dx + dv/dx
;   d(uv)/dx = u(dv/dx) + v(du/dx)
;   d(u^n)/dx = nu^(n-1)(du/dx)
(define (derivation expr var)
    (cond ((number? expr) 0)
          ((variable? expr) (if (same-variable? expr var) 1 0))
          ((sum? expr) (make-sum (derivation (addend expr) var)
                                (derivation (augend expr) var)))
          ((product? expr) (make-sum (make-product (multiplier expr)
                                                  (derivation (multiplicand expr) var))
                                    (make-product (multiplicand expr)
                                                  (derivation (multiplier expr) var))))
          ((and (exponentiation? expr) (=number? (derivation (exponent expr) var) 0)) ; 幂函数而非指数函数
           (make-product (make-product (exponent expr)
                                       (make-exponentiation (base expr)
                                                            (make-sum (exponent expr) -1)))
                         (derivation (base expr) var))
          )
          (else (list 'derivation expr var))
    )
)

; test
; d(xy) / dx = 0*x + 1*y = y
(derivation '(* x y) 'x)
; d(3+x) / dx = 1
(derivation '(+ 3 x) 'x)
; d(xy * (3+x))/dx = 2xy + 3y
(derivation '(* (* x y) (+ x 3)) 'x)
; dx^(10y)/dx = 10y*x^(10y-1)
(derivation '(exp x (* y 10)) 'x)
; dx^x/dx : can not obtian for now.
(derivation '(exp x x) 'x)