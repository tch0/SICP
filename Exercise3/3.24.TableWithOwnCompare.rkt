#lang sicp

(define (make-table same-key?)
    (define local-table (list '*table*))
    (define (my-assoc key records)
        (cond ((null? records) #f)
              ((same-key? key (caar records)) (car records))
              (else (my-assoc key (cdr records)))
        )
    )
    (define (lookup key-1 key-2)
        (let ((subtable (my-assoc key-1 (cdr local-table))))
            (if subtable
                (let ((record (my-assoc key-2 (cdr subtable))))
                    (if record
                        (cdr record)
                        #f
                    )
                )
                #f
            )
        )
    )
    (define (insert! key-1 key-2 value)
        (let ((subtable (my-assoc key-1 (cdr local-table))))
            (if subtable
                ; subtable exist
                (let ((record (my-assoc key-2 (cdr subtable))))
                    (if record
                        ; record exist, modify record
                        (set-cdr! record value)
                        ; record doesn't exist, insert a new record
                        (set-cdr! subtable
                                  (cons (cons key-2 value) (cdr subtable)))
                    )
                )
                ; subtable doesn't exist, insert a new subtable
                (set-cdr! local-table
                          (cons (list key-1 (cons key-2 value))
                                (cdr local-table)))
            )
        )
    )
    (define (dispatch m)
        (cond ((eq? m 'lookup-proc) lookup)
              ((eq? m 'insert-proc) insert!)
              (else (error "Unkown request in make-talbe/dispatch, " m))
        )
    )
    dispatch
)

; put and get
(define operation-table (make-table (lambda (x y) (< (abs (- x y)) 0.1))))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc))

; test
(put 1.0 1.0 'hello)
(get 1.01 1.01)