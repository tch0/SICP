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
(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))

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

; regular arithmetic
; tag: scheme-number
(define (install-scheme-number-package)
    (define (tag x) (attach-tag 'scheme-number x))
    (put 'add '(scheme-number scheme-number) (lambda (x y) (tag (+ x y))))
    (put 'sub '(scheme-number scheme-number) (lambda (x y) (tag (- x y))))
    (put 'mul '(scheme-number scheme-number) (lambda (x y) (tag (* x y))))
    (put 'div '(scheme-number scheme-number) (lambda (x y) (tag (/ x y))))
    (put 'make 'scheme-number (lambda (x) (tag x)))
    ; Ex 2.79
    (put 'equ? '(scheme-number scheme-number) =)
    ; Ex 2.80
    (put '=zero? '(scheme-number) (lambda (x) (= x 0)))
    'done
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
    ; Ex 2.79
    (put 'equ? '(rational rational)
        (lambda (x y)
            (= (* (numer x) (denom y)) (* (denom x) (numer y)))
        )
    )
    ; Ex 2.80
    (put '=zero? '(rational) (lambda (x) (= (numer x) 0)))
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
    ; Ex 2.77
    (put 'real-part '(complex) real-part)
    (put 'imag-part '(complex) imag-part)
    (put 'magnitude '(complex) magnitude)
    (put 'angle '(complex) angle)
    ; Ex 2.79
    (put 'equ? '(complex complex)
        (lambda (x y)
            (and (= (real-part x) (real-part y))
                 (= (imag-part x) (imag-part y)))
        )
    )
    ; Ex 2.80
    (put '=zero? '(complex)
        (lambda (z) (= (real-part z) (imag-part z) 0))
    )
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

; test
(display "original test:\n")
(define PI 3.14159265358979323846)
(install-rectangular-package)
(install-polar-package)
(install-scheme-number-package)
(install-rational-package)
(install-complex-package)
(add (make-scheme-number 1) (make-scheme-number 2))
(sub (make-scheme-number 1) (make-scheme-number 3))
(mul (make-scheme-number 1) (make-scheme-number 2))
(div (make-scheme-number 1) (make-scheme-number 2))
(add (make-rational 1 2) (make-rational 1 3))
(div (make-rational 1 2) (make-rational 1 3))
(add (make-complex-from-real-imag 1 1) (make-complex-from-mag-ang 1 (/ PI 4)))
(div (make-complex-from-real-imag 1 1) (make-complex-from-real-imag 1 0))
(magnitude (make-complex-from-real-imag 3 4))

; Ex 2.79
(define (equ? x y) (apply-generic 'equ? x y))

; test
(newline)
(display "Ex 2.79 test:\n")
(equ? (make-scheme-number 1) (make-scheme-number 2))
(equ? (make-scheme-number 1) (make-scheme-number 1))
(equ? (make-rational 1 2) (make-rational 2 4))
(equ? (make-complex-from-real-imag 1 0) (make-complex-from-mag-ang 1 0)) ; #t

; Ex 2.80
(define (=zero? x) (apply-generic '=zero? x))

; test
(newline)
(display "Ex 2.80 test:\n")
(=zero? (make-scheme-number 0))
(=zero? (make-rational 0 10))
(=zero? (make-complex-from-mag-ang 0 0))
(=zero? (make-complex-from-real-imag 0 0))