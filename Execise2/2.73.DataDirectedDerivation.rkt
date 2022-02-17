#lang sicp

; auxiliary functions
; from 2DataAbstraction/P100.SymbolicDerivation.rkt
(define (=number? exp num)
    (and (number? exp) (= exp num))
)
(define (variable? e) (symbol? e))
(define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2))
)

; from 2DataAbstraction/P117.ComplexOperations.rkt
; data with tags
(define (attach-tag type-tag contents)
    (cons type-tag contents)
)
(define (type-tag datum)
    (if (pair? datum)
        (car datum)
        (error "Bad tagged datum -- in function type-tag, " datum)
    )
)
(define (contents datum)
    (if (pair? datum)
        (cdr datum)
        (error "Bad tagged datum -- in function contents, " datum)
    )
)

; ==============================================================================
; implementation of put and get is from 3MutableData/P186.Table.rkt
(define (make-table) (list '*table*))
(define (lookup2 key-1 key-2 table)
    (let ((subtable (assoc key-1 (cdr table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
                (if record
                    (cdr record)
                    #f
                )
            )
            #f
        )
    )
)
(define (insert2! key-1 key-2 value table)
    (let ((subtable (assoc key-1 (cdr table))))
        (if subtable
            ; subtable exist
            (let ((record (assoc key-2 (cdr subtable))))
                (if record
                    (set-cdr! record value) ; modify record
                    (set-cdr! subtable
                              (cons (cons key-2 value) (cdr subtable))) ; add record
                )
            )
            ; subtable doesn't exist, insert a subtable
            (set-cdr! table
                      (cons (list key-1 (cons key-2 value)) ; inner subtable
                            (cdr table))
            )
        )
    )
)

(define *table* (make-table)) ; a global table
; put an item to table
(define (put op type item)
    (insert2! op type item *table*)
)
; get an item from table, return #f if not in the table
(define (get op type)
    (lookup2 op type *table*)
)
; ==============================================================================

; modify symbolic derivation program to data oriented style
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (derivation exp var)
    (cond ((number? exp) 0)
          ((variable? exp) (if (same-variable? exp var) 1 0))
          (else ((get 'derivation (operator exp)) exp ;(operands exp) ; use exp instead of (operands exp) in the book.
                                                  var))
    )
)

; b)
; accomplish deviration procedures of summation and multiplication, then install them
(define (install-sum-deriv-package)
    (define (addend exp) (cadr exp))
    (define (augend exp) (caddr exp))
    (define (make-sum-inner a1 a2)
        (cond  ((=number? a1 0) a2)
               ((=number? a2 0) a1)
               ((and (number? a1) (number? a2)) (+ a1 a2))
               (else (list '+ a1 a2))
        )
    )
    (define (deriv-sum exp var)
        (make-sum (derivation (addend exp) var)
                  (derivation (augend exp) var))
    )
    (put 'derivation '+ deriv-sum)
    (put 'make-sum '+ make-sum-inner)
    'dene
)

(define (install-product-deriv-package)
    (define (multiplier exp) (cadr exp))
    (define (multiplicand exp) (caddr exp))
    (define (make-product-inner m1 m2)
        (cond ((or (=number? m1 0) (=number? m2 0)) 0)
              ((=number? m1 1) m2)
              ((=number? m2 1) m1)
              ((and (number? m1) (number? m2)) (* m1 m2))
              (else (list '* m1 m2))
        )
    )
    (define (deriv-product exp var)
        (make-sum (make-product (multiplier exp)
                                (derivation (multiplicand exp) var))
                  (make-product (multiplicand exp)
                                (derivation (multiplier exp) var))
        )
    )
    (put 'derivation '* deriv-product)
    (put 'make-product '* make-product-inner)
    'done
)
(define (make-sum x y) ((get 'make-sum '+) x y))
(define (make-product x y) ((get 'make-product '*) x y))

; install
(install-sum-deriv-package)
(install-product-deriv-package)

; c)
; add derivation of exponential function
(define (install-exponential-deriv-package)
    (define (base exp) (cadr exp))
    (define (exponent exp) (caddr exp))
    (define (make-exponentiation-inner base exponent)
        (cond ((and (=number? base 0) (=number? exponent 0)) (error "0^0 has no meaning." base exponent))
              ((=number? base 0) 0)
              ((=number? exponent 0) 1)
              ((=number? exponent 1) base)
              ((and (number? base) (number? exponent)) (expt base exponent))
              (else (list 'exp base exponent))
        )
    )
    (define (deriv-exponentiation exp var)
        (make-product (make-product (exponent exp)
                                    (make-exponentiation (base exp)
                                                         (make-sum (exponent exp) -1)))
                      (derivation (base exp) var)
        )
    )
    (put 'derivation 'exp deriv-exponentiation)
    (put 'make-exponentiation 'exp make-exponentiation-inner)
    'done
)
(define (make-exponentiation x y) ((get 'make-exponentiation 'exp) x y))

; install 
(install-exponential-deriv-package)

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
; (derivation '(exp x x) 'x)