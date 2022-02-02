#lang sicp

; auxiliary functions
(define (=number? exp num)
    (and (number? exp) (= exp num))
)
(define (variable? e) (symbol? e))
(define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2))
)

; list auxiliary functions
(define (fold-left op initial sequence)
    (if (null? sequence)
        initial
        (fold-left op (op initial (car sequence)) (cdr sequence))
    )
)
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)

; do not change derivation
; d exp / d var
; derivation rules:
;   dc/dx = 0, c is a constant
;   dx/dx = 1
;   d(u+v)/dx = du/dx + dv/dx
;   d(uv)/dx = u(dv/dx) + v(du/dx)
(define (derivation expr var)
    (cond ((number? expr) 0)
          ((variable? expr) (if (same-variable? expr var) 1 0))
          ((sum? expr) (make-sum (derivation (addend expr) var)
                                (derivation (augend expr) var)))
          ((product? expr) (make-sum (make-product (multiplier expr)
                                                  (derivation (multiplicand expr) var))
                                    (make-product (multiplicand expr)
                                                  (derivation (multiplier expr) var))))
          (else (list 'derivation expr var))
    )
)

; 和式
(define (sum? e)
    (and (pair? e) (eq? (car e) '+))
)        ; e是和式吗？

(define (addend e)
    (if (< (length e) 2)
        0
        (cadr e))
)        ; e的被加数

(define (augend e)
    (cond ((< (length e) 3) 0)
          ((= (length e) 3) (caddr e))
          (else (cons '+ (cddr e))))
)       ; e的加数

; do some simplification work
; seems it's not necessary for make-sum to have varied-number parameters.
(define (make-sum . numlist)
    ; accumulate all numbers, then cons other non-number elements to be the final list.
    (let ((simplified-numlist (cons (fold-left (lambda (res x) (if (number? x) (+ res x) res))
                                               0
                                               numlist)
                                    (filter (lambda (x) (not (number? x))) numlist))))
        (cond ((= (length simplified-numlist) 1) (car simplified-numlist))
              ((= (car simplified-numlist) 0) (if (= (length (cdr simplified-numlist)) 1)
                                                  (cadr simplified-numlist)
                                                  (cons '+ (cdr simplified-numlist))))
              (else (cons '+ simplified-numlist))
        )
    )
)       ; 构建a1和a2的和式

; 乘式
(define (product? e)
    (and (pair? e) (eq? (car e) '*))
)   ; e是乘式吗？

(define (multiplier e)
    (if (< (length e) 2)
        1
        (cadr e))
)   ; e的被乘数

(define (multiplicand e)
    (cond ((< (length e) 3) 1)
          ((= (length e) 3) (caddr e))
          (else (cons '* (cddr e)))
    )
)   ; e的乘数

(define (make-product . numlist)
    (let ((simplified-numlist (cons (fold-left (lambda (res x) (if (number? x) (* res x) res))
                                               1
                                               numlist)
                                    (filter (lambda (x) (not (number? x))) numlist))))
        (cond ((= (length simplified-numlist) 1) (car simplified-numlist))
              ((=number? (car simplified-numlist) 0) 0)
              ((=number? (car simplified-numlist) 1) (if (= (length (cdr simplified-numlist)) 1)
                                                         (cadr simplified-numlist)
                                                         (cons '* (cdr simplified-numlist))))
              (else (cons '* simplified-numlist))
        )
    )
)       ; 构建起m1和m2的乘式

; test
; d(xy) / dx = 0*x + 1*y = y
(derivation '(* x y x) 'x)
; d(3+x+x+x) / dx = 3
(derivation '(+ 3 x x x) 'x)
; d(xy * (3+x))/dx = 2xy + 3y
(derivation '(* (* x y) (+ x 3)) 'x)
; 2xy + 3y
(derivation '(* x y (+ x 3)) 'x)