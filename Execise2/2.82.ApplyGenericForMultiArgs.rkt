#lang sicp

; auxiliary functions
(define (square x) (* x x))
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


; example: generic arithmetic system
; ===================== add sub mul div ==============================
;  add-rat sub-rat     |add-complex sub-complex| 
;  mul-rat div-rat     |mul-complex div-complex|   +-*/
;  rational arithmetic |  complex arithmetic   | regular arithmetic
;                      |rectangular|    polar  |

; define generic operations that can be applied for multiple data types.
; (define (add x y) (apply-generic 'add x y))
(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))

; regular arithmetic
; tag: scheme-number
(define (install-scheme-number-package)
    (define (tag x) (attach-tag 'scheme-number x))
    (put 'add '(scheme-number scheme-number) (lambda (x y) (tag (+ x y))))
    (put 'sub '(scheme-number scheme-number) (lambda (x y) (tag (- x y))))
    (put 'mul '(scheme-number scheme-number) (lambda (x y) (tag (* x y))))
    (put 'div '(scheme-number scheme-number) (lambda (x y) (tag (/ x y))))
    (put 'make 'scheme-number (lambda (x) (tag x)))
)
(define (make-scheme-number x) ((get 'make 'scheme-number) x))

; rational arithmetic
; tag: rational
(define (install-rational-package)
    ; internal percedures
    ; rational arthmetic funtions from 2DataAbstraction/P56.RationalArithmetic.rkt
    (define (make-rat n d)
        (let ((g (gcd n d)))
            (cons (/ n g) (/ d g))
        )
    )
    (define (numer x) (car x))
    (define (denom x) (cdr x))
    ; n1/d1 + n2/d2 = (n1d2 + n2d1)/d1d2
    (define (add-rat x y)
        (make-rat (+ (* (numer x) (denom y))
                     (* (numer y) (denom x)))
                  (* (denom x) (denom y))
        )
    )
    ; n1/d1 - n2/d2 = (n1d2 - n2d1)/d1d2
    (define (sub-rat x y)
        (make-rat (- (* (numer x) (denom y))
                     (* (numer y) (denom x)))
                  (* (denom x) (denom y))
        )
    )
    ; n1/d1 * n2/d2 = n1n2/d1d2
    (define (mul-rat x y)
        (make-rat (* (numer x) (numer y))
                  (* (denom x) (denom y))
        )
    )
    ; (n1/d1) / (n2/d2) = n1d2/n2d1
    (define (div-rat x y)
        (make-rat (* (numer x) (denom y))
                  (* (numer y) (denom x))
        )
    )
    ; interfaces to rest of the system
    (define (tag x) (attach-tag 'rational x))
    (put 'add '(rational rational) (lambda (x y) (tag (add-rat x y))))
    (put 'sub '(rational rational) (lambda (x y) (tag (sub-rat x y))))
    (put 'mul '(rational rational) (lambda (x y) (tag (mul-rat x y))))
    (put 'div '(rational rational) (lambda (x y) (tag (div-rat x y))))
    (put 'make 'rational (lambda (n d) (tag (make-rat n d))))
    'done
)
(define (make-rational n d) ((get 'make 'rational) n d))

; ================================================================================
; from 2DataAbstraction\P123.DataDirectedProgramming.rkt
; rectangular package
(define (install-rectangular-package)
    ; internal procedures
    (define (real-part z) (car z))
    (define (imag-part z) (cdr z))
    (define (make-from-real-imag x y) (cons x y))
    (define (magnitude z)
        (sqrt (+ (square (real-part z))
                 (square (imag-part z))))
    )
    (define (angle z)
        (atan (imag-part z) (real-part z))
    )
    (define (make-from-mag-ang r a)
        (cons (* r (cos a)) (* r (sin a)))
    )
    ; interfaces to the rest of the system
    (define (tag x) (attach-tag 'rectangular x))
    (put 'real-part '(rectangular) real-part) ; use list of tags as type
    (put 'imag-part '(rectangular) imag-part)
    (put 'magnitude '(rectangular) magnitude)
    (put 'angle '(rectangular) angle)
    (put 'make-from-real-imag 'rectangular ; just use tag as type
        (lambda (x y) (tag (make-from-real-imag x y)))
    )
    (put 'make-from-mag-ang 'rectangular
        (lambda (r a) (tag (make-from-mag-ang r a)))
    )
    'done ; return value, no meaning
)

; polar package
(define (install-polar-package)
    ; internal procedures from rectangular and polar packages
    (define (magnitude z) (car z))
    (define (angle z) (cdr z))
    (define (make-from-mag-ang r a) (cons r a))
    (define (real-part z) (* (magnitude z) (cos (angle z))))
    (define (imag-part z) (* (magnitude z) (sin (angle z))))
    (define (make-from-real-imag x y)
        (cons (sqrt (+ (square x) (square y)))
              (atan y x))
    )
    ; interfaces to the rest of the system
    (define (tag x) (attach-tag 'polar x))
    (put 'real-part '(polar) real-part) ; use list of tags as type
    (put 'imag-part '(polar) imag-part)
    (put 'magnitude '(polar) magnitude)
    (put 'angle '(polar) angle)
    (put 'make-from-real-imag 'polar ; just use tag as type
        (lambda (x y) (tag (make-from-real-imag x y)))
    )
    (put 'make-from-mag-ang 'polar
        (lambda (r a) (tag (make-from-mag-ang r a)))
    )
    'done
)
; ================================================================================

; complex arithmetic
; tag: complex
(define (install-complex-package)
    ; import procedures from rectangular and polar packages
    (define (make-from-real-imag x y) ((get 'make-from-real-imag 'rectangular) x y))
    (define (make-from-mag-ang r a) ((get 'make-from-mag-ang 'polar) r a))
    ; internal procedures
    ; from 2DataAbstraction/P123.DataDirectedProgramming.rkt
    (define (add-complex z1 z2)
        (make-from-real-imag (+ (real-part z1) (real-part z2))
                             (+ (imag-part z1) (imag-part z2)))
    )
    (define (sub-complex z1 z2)
        (make-from-real-imag (- (real-part z1) (real-part z2))
                             (- (imag-part z1) (imag-part z2)))
    )
    (define (mul-complex z1 z2)
        (make-from-mag-ang (* (magnitude z1) (magnitude z2))
                           (+ (angle z1) (angle z2)))
    )
    (define (div-complex z1 z2)
        (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                           (- (angle z1) (angle z2)))
    )
    ; interfaces to rest of the system
    ; two layers of tags, complex and rectangular/polar
    (define (tag z) (attach-tag 'complex z))
    (put 'add '(complex complex) (lambda (z1 z2) (tag (add-complex z1 z2))))
    (put 'sub '(complex complex) (lambda (z1 z2) (tag (sub-complex z1 z2))))
    (put 'mul '(complex complex) (lambda (z1 z2) (tag (mul-complex z1 z2))))
    (put 'div '(complex complex) (lambda (z1 z2) (tag (div-complex z1 z2))))
    (put 'make-from-real-imag 'complex
        (lambda (x y) (tag (make-from-real-imag x y)))
    )
    (put 'make-from-mag-ang 'complex
        (lambda (r a) (tag (make-from-mag-ang r a)))
    )
    (put 'real-part '(complex) real-part)
    (put 'imag-part '(complex) imag-part)
    (put 'magnitude '(complex) magnitude)
    (put 'angle '(complex) angle)
    'done
)
(define (make-complex-from-real-imag x y)
    ((get 'make-from-real-imag 'complex) x y)
)
(define (make-complex-from-mag-ang r a)
    ((get 'make-from-mag-ang 'complex) r a)
)
(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))

; =======================================================================
; all above is from 2DataAbstraction/P129.GenericOperations.rkt
; =======================================================================
; coercion table from 2DataAbstraction/P133.CoercionProcedures.rkt
(define *coercion-table* (make-table))
(define (put-coercion from-type to-type item)
    (insert2! from-type to-type item *coercion-table*)
)
(define (get-coercion from-type to-type)
    (lookup2 from-type to-type *coercion-table*)
)

; cast procedures
(define (scheme-number->complex n)
    (make-complex-from-real-imag (contents n) 0)
)
; install coercion procedures to table, not all casts can be applied
(define (install-corecoin-package)
    (put-coercion 'scheme-number 'complex scheme-number->complex)
    'done
)

; ===========================================Ex 2.82===========================================
; a new apply-generic that take care of cast procedures, and multiple arguments
(define (apply-generic op . args)
    (define (same-type type-tags) ; type-tags should not be nil
        (define (iter rest first)
            (cond ((null? rest) #t)
                  ((equal? first (car rest)) (iter (cdr rest) first))
                  (else #f)
            )
        )
        (iter (cdr type-tags) (car type-tags))
    )
    (define (any-false? in-list)
        (cond ((null? in-list) #f)
              ((not (car in-list)) #t)
              (else (any-false? (cdr in-list)))
        )
    )
    ; cast all arguments to target-type, if can not cast, get a false
    (define (cast args target-type)
        (map (lambda (arg)
                (if (equal? (type-tag arg) target-type) ; same type, do not need to cast
                    arg
                    (let ((cast-func (get-coercion (type-tag arg) target-type)))
                        (if cast-func
                            (cast-func arg) ; cast success
                            #f ; can not cast
                        )
                    )
                )
             )
             args
        )
    )
    ; error prompt
    (define (no-method-prompt type-tags)
        (error "No method for these types -- in function apply-generic, "
                (list op type-tags))
    )
    ; try to cast all arguments to every type
    (define (coercion args type-tags)
        (define (iter rest-target-types)
            (if (null? rest-target-types)
                (no-method-prompt type-tags)
                (let ((cast-result (cast args (car rest-target-types))))
                    (if (any-false? cast-result)
                        (iter (cdr rest-target-types)) ; at least one argument can not be casted to target type
                        (apply apply-generic (cons op cast-result)) ; all arguments can be casted
                    )
                )
            )
        )
        (iter type-tags)
    )
    (let ((type-tags (map type-tag args))) ; use list of tags as type
        (let ((proc (get op type-tags)))
            (if proc
                ; find procedure
                (apply proc (map contents args))
                ; no such a procedure
                (if (same-type type-tags)
                    (no-method-prompt type-tags) ; all arguments are same type
                    (coercion args type-tags) ; not same type, try coercion
                )
            )
        )
    )
)

; install all packages
(install-rectangular-package)
(install-polar-package)
(install-scheme-number-package)
(install-rational-package)
(install-complex-package)
(install-corecoin-package)
; test
(add (make-scheme-number 1) (make-complex-from-real-imag 1 2))
(add (make-complex-from-real-imag 1 2) (make-scheme-number 1))