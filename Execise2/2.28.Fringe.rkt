#lang sicp

; http://community.schemewiki.org/?sicp-ex-2.28
; fringe of a tree: list contain all leaves of a tree
; first attempt: recursion and using append.
(define (fringe tree)
    (cond ((null? tree) nil)
          ((list? tree) (append (fringe (car tree)) (fringe (cdr tree))))
          (else (list tree))
    )
)

; pure iterative solution that do not use append.
; more efficient than first one, more complicated.
; from rohitkg98
(define (fringe2 tree)
    (define (iter first rest result)
        (cond ((and (null? first) (null? rest)) result)
              ((null? first) (iter (car rest) (cdr rest) result))
              ((list? first) (iter (car first) (cons (cdr first) rest) result))
              (else (iter (car rest) (cdr rest) (cons first result)))
        )
    )
    (reverse (iter nil tree nil))
)

; do not use append, not pure iteration, but simpler than fringe2.
; from Daniel-Amariei
(define (fringe3 tree)
    (define (iter tree result)
        (cond ((null? tree) result)
              ((list? tree) (iter (car tree) (iter (cdr tree) result)))
              (else (cons tree result))
        )
    )
    (iter tree nil)
)

; expected efficiency : fringe2 > fringe3 > fringe1

; test
(define test-tree (list (list (list 1 2 3 19 283 38) 2 3 2) (list 2 3 (list 217 382 1827) 2 187 (list 2838)) 2 1 2 (list 2 (list 3 (list 3)) 23 2 1 238)))
; result: (1 2 3 19 283 38 2 3 2 2 3 217 382 1827 2 187 2838 2 1 2 2 3 3 23 2 1 238)
(fringe test-tree)
(fringe2 test-tree)
(fringe3 test-tree)