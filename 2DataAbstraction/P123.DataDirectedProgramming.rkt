#lang sicp

; auxiliary functions
(define (square x) (* x x))

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

; ==================================================================================
; data-directed programming, diaptching data to different procedures according to data types automatically

; maintain a table of data types to precedures should call
; more information about how to implement such a table, see Section 3.3.3, Ex 3.24

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
; ==================================================================================

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
    ; internal procedures
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

; a generic apply
(define (apply-generic op . args)
    (let ((type-tags (map type-tag args))) ; use list of tags as type
        (let ((proc (get op type-tags)))
            (if proc
                (apply proc (map contents args))
                (error "No method for these types -- in function apply-generic, "
                       (list op (type-tags)))
            )
        )
    )
)

; generic selectors that use apply-generic.
(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))

; constructors that read from the table
(define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y)
)
(define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a)
)

; operations: +-*/, constructed above the representation of complex numbers
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

; test
(define PI 3.14159265358979323846)
(install-rectangular-package)
(install-polar-package)
(add-complex (make-from-real-imag 1 1) (make-from-mag-ang 2 (/ PI 4)))
(mul-complex (make-from-real-imag 1 1) (make-from-mag-ang 2 (/ PI 4)))