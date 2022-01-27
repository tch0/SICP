#lang sicp

; using high order function abstract operations about sequence, sequence(list) as interface.

; =======================================================================================
; enumerate(tree leaves) --> filter(odd?) --> map(square) --> accumulate(+,0)
(define (square x) (* x x))
(define (sum-odd-squares tree)
    (cond ((null? tree) 0)
          ((not (list? tree)) (if (odd? tree) (square tree) 0))
          (else (+ (sum-odd-squares (car tree))
                   (sum-odd-squares (cdr tree))))
    )
)

; enumerate(integers) --> map(fibonacci) --> filter(even?) --> accumulate(cons,())
(define (fib n)
    (define (fib-iter a b count)
        (if (= count 0)
            b
            (fib-iter (+ a b) a (- count 1))
        )
    )
    (fib-iter 1 0 n)
)
(define (even-fibs n)
    (define (next k)
        (if (> k n)
            nil
            (let ((f (fib k)))
                (if (even? f)
                    (cons f (next (+ k 1)))
                    (next (+ k 1)))
            )
        )
    )
    (next 0)
)

; test of plain implementation
(display "plain implementation test:\n")
(sum-odd-squares (list (list 1 2 3) (list 4 5 6)))
(even-fibs 10)
(newline)

; =======================================================================================
; implement high order functions

; filter
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)

; accumulate (from right to left, aka foldr)
(define (accumulate op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (accumulate op initial (cdr sequence)))
    )
)

; high order function tests
(display "high order function test:\n")
(filter odd? (list 1 2 3 4 5))
(accumulate cons nil (list 1 2 3 4))
(accumulate + 0 (list 1 2 3 4))
(newline)

; =======================================================================================
; equivalent sum-odd-squares and even-fibs that use high order functions

; first enumerate leaves of a tree, see 2.28.Fringe.rkt
(define (enumerate-tree tree)
    (cond ((null? tree) nil)
          ((list? tree) (append (enumerate-tree (car tree)) (enumerate-tree (cdr tree))))
          (else (list tree))
    )
)

; enumerate(tree leaves) --> filter(odd?) --> map(square) --> accumulate(+,0)
(define (sum-odd-squares2 tree)
    (accumulate +
                0
                (map square
                     (filter odd? (enumerate-tree tree)))
    )
)

; enumerate integers in interval
(define (enumerate-interval low high)
    (if (> low high)
        nil
        (cons low (enumerate-interval (+ low 1) high))
    )
)
; enumerate(integers) --> map(fibonacci) --> filter(even?) --> accumulate(cons,())
(define (even-fibs2 n)
    (accumulate cons
                nil
                (filter even?
                        (map fib (enumerate-interval 0 n)))
    )
)

; implementation using high order function test
(display "implementation using high order function test:\n")
(sum-odd-squares2 (list (list 1 2 3) (list 4 5 6)))
(even-fibs2 10)
(newline)