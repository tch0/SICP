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
(define (singleton? l)
    (and (list? l) (= (length l) 1))
)
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

; operator auxiliary functions
; find the smallest precedence operator
(define (smallest-operator expr)
    (define precedence-list '(+ *)) ; precedence in asending order
    (define (list-index item sequence)
        (define (iter item count rest)
            (cond ((null? rest) -1)
                  ((equal? item (car rest)) count)
                  (else (iter item (+ 1 count) (cdr rest)))
            )
        )
        (iter item 0 sequence)
    )
    (define (min-precedence res item)
        (cond ((= (list-index item precedence-list) -1) res) ; not an operator
              ((> (list-index res precedence-list) (list-index item precedence-list)) item)
              (else res)
        )
    )
    (fold-left min-precedence '* expr)
)

; a) is trivial
; b) include all cases of a), so I only finish b).

; auxiliary function
; prefix of specific symbol in a list
(define (prefix sym items)
    (if (or (null? items) (eq? sym (car items)))
        nil
        (cons (car items) (prefix sym (cdr items)))
    )
)

(define (sum? e)
    (equal? '+ (smallest-operator e))
)
(define (make-sum a1 a2)
    (cond ((=number? a1 0) a2)
          ((=number? a2 0) a1)
          ((and (number? a1) (number? a2)) (+ a1 a2))
          (else (list a1 '+ a2))
    )
)
(define (addend e)
    (let ((a (prefix '+ e)))
        (if (singleton? a)
            (car a)
            a)
    )
)
(define (augend e)
    ; make singleton list like (1) ('x) be just the first element.
    (let ((a (cdr (memq '+ e))))
        (if (singleton? a)
            (car a)
            a)
    )
)

(define (product? e)
    (equal? '* (smallest-operator e))
)
(define (make-product m1 m2)
    (cond ((or (=number? m1 0) (=number? m2 0)) 0)
          ((=number? m1 1) m2)
          ((=number? m2 1) m1)
          ((and (number? m1) (number? m2)) (* m1 m2))
          (else (list m1 '* m2))
    )
)
(define (multiplier e)
    (let ((a (prefix '* e)))
        (if (singleton? a)
            (car a)
            a)
    )
)
(define (multiplicand e)
    (let ((a (cdr (memq '* e))))
        (if (singleton? a)
            (car a)
            a)
    )
)

; test
(derivation '(x + x) 'x) ; 2x
(derivation '(x * x + x * x + x) 'x) ; 4x + 1
(derivation '(x * x * x * x + (x * x * x + x * x + x) + x) 'x) ; 4x^3 + 3x^2 + 2x + 2
(derivation '(x + y * x * y) 'x) ; 1 + y^2