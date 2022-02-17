#lang sicp

; implentation of table/dictionary

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

; test
(newline)
(define test-table '(*table* (a . 1) (b . 2) (c . 3)))
(display "1d table test:\n")
(lookup 'a test-table)
(lookup 'd test-table)
(insert! 'd 10 test-table)
test-table

; two dimension table
; construct a one dimension table that the element of table is also a one dimension table
; inner table doesn't need the first special head symbol, just let the first key be this node.
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

(define test-table2 '(*table* (a (b . 1) (c . 2))))

; test
(newline)
(display "2d table test:\n")
(lookup2 'a 'c test-table2)
(insert2! 'test1 'test2 100 test-table2)
test-table2

; get and put in previous section (Chapter 2)
(define *table* (make-table)) ; a global table
(define (put op type item)
    (insert2! op type item *table*)
)
(define (get op type)
    (lookup2 op type *table*)
)

; test of put and get
(newline)
(display "test of put and get:\n")
(put "hello" "world" "yes")
(put "hello" "scheme" "no")
(put '(1 2 3 (4 . 5)) '(test) 'nice)
(put '(1 2 3 (4 . 5)) '(test) 'hapy)
(get "hello" "world")
(get '(1 2 3 (4 . 5)) '(test))
(get 100 101)