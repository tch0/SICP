#lang sicp

; an arbitrary n-dimension table

; One dimensional table from 3MutableData/P186.Table.rkt
; look up value according to given key
(define (lookup key table)
    (let ((record (assoc key (cdr table))))
        (if record
            (cdr record)
            #f)
    )
)

; insert value for given key to table
(define (insert! key value table)
    (let ((record (assoc key (cdr table))))
        (if record
            (set-cdr! record value)
            (set-cdr! table (cons (cons key value) (cdr table)))
        )
    )
)
(define (make-table) (list '*table*))

; implementation of arbitrary n-dimension table
; from http://community.schemewiki.org/?sicp-ex-3.25 by antbbn, it's so brilliant
(define (table? t)
    (and (pair? t) (eq? '*table* (car t)))
)
(define (lookup-generic table key . rest-of-keys)
    (let ((subtable-or-record (lookup key table)))
        (cond ((not subtable-or-record) #f) ; do not find
              ((null? rest-of-keys) subtable-or-record) ; return the found record or subtable
              ((table? subtable-or-record) (apply lookup-generic subtable-or-record rest-of-keys))
              (else (error "Key is not a subtable -- in look-generic, " key subtable-or-record))
        )
    )
)
(define (insert-generic! table value key . rest-of-keys)
    (if (null? rest-of-keys) ; on the last key
        (insert! key value table)
        (let ((subtable-or-record (lookup key table)))
            (if (table? subtable-or-record)
                (apply insert-generic! subtable-or-record value rest-of-keys)
                (let ((new-subtable (make-table)))
                    (insert! key new-subtable table)
                    (apply insert-generic! new-subtable value rest-of-keys)
                )
            )
        )
    )
)

; test
(define t (make-table))
(insert-generic! t 10 'a 'a 'a)
(insert-generic! t 100 'a 'b 'c)
(lookup-generic t 'a 'a)
(lookup-generic t 'a 'a 'a)
(lookup-generic t 'a 'b 'c)
(lookup-generic t 'a 'b 'e)
t