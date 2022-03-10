#lang sicp

; ==============================================================================
; data with tags, from 2DataAbstraction/P117.ComplexOperations.rkt
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
; from 2DataAbstraction/P123.DataDirectedProgramming.rkt
(define (apply-generic op . args)
    (let ((type-tags (map type-tag args))) ; use list of tags as type
        (let ((proc (get op type-tags)))
            (if proc
                (apply proc (map contents args))
                (error "No method for these types -- in function apply-generic, "
                       (list op type-tags))
            )
        )
    )
)
; ==============================================================================

; polynomial package
; tag : polynomial
(define (install-polynomial-package)
    ; internal procedures
    ; representation of poly
    (define (make-poly var terms) (cons var terms))
    (define (variable p) (car p))
    (define (term-list p) (cdr p))
    (define (variable? e) (symbol? e))
    (define (same-variable? v1 v2)
        (and (variable? v1) (variable? v2) (eq? v1 v2))
    )
    ; representation of term and term list
    (define (the-empty-termlist) nil)
    (define (empty-termlist? tl) (null? tl))
    (define (adjoin-term term termlist)
        (if (=zero? (coeff term))
            termlist
            (cons term termlist)
        )
    ) ; add term to term list
    (define (first-term termlist) (car termlist)) ; return highgest rank term in the term list
    (define (rest-terms termlist) (cdr termlist)) ; return rest term (as a term list) except first-term
    (define (make-term order coeff) (list order coeff)) ; construct a term
    (define (order term) (car term)) ; select order of a term
    (define (coeff term) (cadr term)) ; select coefficient of a term
    ; Ex 2.87
    (define (poly=zero? poly)
        (empty-termlist? (term-list poly))
    )
    ; operation of terms
    (define (add-terms L1 L2)
        (cond ((empty-termlist? L1) L2)
              ((empty-termlist? L2) L1)
              (else
               (let ((t1 (first-term L1))
                     (t2 (first-term L2)))
                    (cond ((> (order t1) (order t2)) (adjoin-term t1 (add-terms (rest-terms L1) L2)))
                          ((< (order t1) (order t2)) (adjoin-term t2 (add-terms L1 (rest-terms L2))))
                          (else (adjoin-term (make-term (order t1)
                                                        (add (coeff t1) (coeff t2))) ; use general add except + (so coeff can be a polynomial of another varaible)
                                             (add-terms (rest-terms L1)
                                                        (rest-terms L2)))
                          )
                    )
               ))
        )
    )
    ; auxiliary function of mul-terms
    (define (mul-terms-by-all-terms t1 L)
        (if (empty-termlist? L)
            (the-empty-termlist)
            (let ((t2 (first-term L)))
                (adjoin-term (make-term (+ (order t1) (order t2))
                                        (mul (coeff t1) (coeff t2))) ; use general mul
                             (mul-terms-by-all-terms t1 (rest-terms L))
                )
            )
        )
    )
    (define (mul-terms L1 L2)
        (if (empty-termlist? L1)
            (the-empty-termlist)
            (add-terms (mul-terms-by-all-terms (first-term L1) L2)
                       (mul-terms (rest-terms L1) L2)
            )
        )
    )
    ; arithmetic of polynomial
    (define (add-poly p1 p2)
        (if (same-variable? (variable p1) (variable p2))
            (make-poly (variable p1)
                      (add-terms (term-list p1)
                                 (term-list p2))
            )
            (error "polys not in same var -- in function add-poly, " (list p1 p2))
        )
    )
    (define (mul-poly p1 p2)
        (if (same-variable? (variable p1) (variable p2))
            (make-poly (variable p1)
                       (mul-terms (term-list p1)
                                  (term-list p2))
            )
            (error "polys not in same var -- in function mul-poly, " (list p1 p2))
        )
    )
    ; interface to rest of the system
    (define (tag p) (attach-tag 'polynomial p))
    (put 'add '(polynomial polynomial) (lambda (p1 p2) (tag (add-poly p1 p2))))
    (put 'mul '(polynomial polynomial) (lambda (p1 p2) (tag (mul-poly p1 p2))))
    (put 'make 'polynomial (lambda (var terms) (tag (make-poly var terms))))
    (put '=zero? 'polynomial (lambda (x) (if (number? x) (= x 0) (poly=zero? x))))
)

; take care of numbers
; need take care of number and poly yet, but add the logic to here is not a good choice.
(define (add x y)
    (if (and (number? x) (number? y))
        (+ x y)
        (apply-generic 'add x y)
    )
)
(define (mul x y)
    (if (and (number? x) (number? y))
        (* x y)
        (apply-generic 'mul x y)
    )
)
(define (make-polynomial var terms) ((get 'make 'polynomial) var terms))
(define (=zero? x) ((get '=zero? 'polynomial) x))

(install-polynomial-package)

; test
; 2x^2 + x + 3
(define p1 (make-polynomial 'x '((2 2) (1 1) (0 3))))
; x
(define p2 (make-polynomial 'x '((1 1))))

(add p1 p2)
(mul p1 p2)