#lang sicp

(define (make-table)
    (define local-table (list '*table*))
    (define (lookup key-1 key-2)
        (let ((subtable (assoc key-1 (cdr local-table))))
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
    (define (insert! key-1 key-2 value)
        (let ((subtable (assoc key-1 (cdr local-table))))
            (if subtable
                ; subtable exist
                (let ((record (assoc key-2 (cdr subtable))))
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
(define operation-table (make-table))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc))

; test
(put 'GoldenFairy 'Nephren 'NephrenRuqInsania)
(put 'GoldenFairy 'Chtholly 'ChthollyNotaSeniorious)
(put 'Human 'Williem 'WilliemKmetsch)
(get 'GoldenFairy 'Chtholly)
(get 'GoldenFairy 'Ithea)